local Core = exports.vorp_core:GetCore()

local SAVE_RANGE = 6.0
local CHARACTER_TRIES = 30
local DEFAULT_RADIUS = 1.5

local busy = {}

local function dprint(...)
  if Config.Debug then print("[bzhar_makeup]", ...) end
end

local function usedCharacter(source)
  local user = Core.getUser(source)
  if not user then return nil end
  local character = user.getUsedCharacter
  if not character or not character.charIdentifier then return nil end
  return character
end

local function nearShop(source)
  local ped = GetPlayerPed(source)
  if not ped or ped == 0 then return true end
  local coords = GetEntityCoords(ped)
  for i = 1, #Config.Locations do
    local location = Config.Locations[i]
    if #(coords - location.coords) <= (location.radius or DEFAULT_RADIUS) + SAVE_RANGE then return true end
  end
  return false
end

local function loadLook(charIdentifier)
  local row = MySQL.single.await("SELECT `layers` FROM `bzhar_makeup` WHERE `charidentifier` = ?", { charIdentifier })
  if not row or not row.layers then return {} end
  local ok, decoded = pcall(json.decode, row.layers)
  if not ok or type(decoded) ~= "table" then return {} end
  return Makeup.CleanLook(decoded)
end

local function saveLook(charIdentifier, look)
  MySQL.query.await([[
    INSERT INTO `bzhar_makeup` (`charidentifier`, `layers`)
    VALUES (?, ?)
    ON DUPLICATE KEY UPDATE `layers` = VALUES(`layers`)
  ]], { charIdentifier, json.encode(look) })
end

local function handleSave(source, payload)
  local character = usedCharacter(source)
  if not character then return end
  if not nearShop(source) then
    TriggerClientEvent("bzhar_makeup:saveResult", source, false, "too_far")
    return
  end
  local look = Makeup.CleanLook(payload)
  local saved = loadLook(character.charIdentifier)
  local price = Makeup.GetTotal(look, saved)
  if price > 0 then
    local balance = character.money
    if Config.Currency == 1 then balance = character.gold end
    balance = tonumber(balance) or 0.0
    if balance < price then
      TriggerClientEvent("bzhar_makeup:saveResult", source, false, "no_money")
      return
    end
    character.removeCurrency(Config.Currency, price)
  end
  saveLook(character.charIdentifier, look)
  TriggerClientEvent("bzhar_makeup:saveResult", source, true)
  dprint("saved look for character", character.charIdentifier, "price", price)
end

RegisterNetEvent("bzhar_makeup:save", function(payload)
  local source = source
  if busy[source] then return end
  busy[source] = true
  local ok, err = pcall(handleSave, source, payload)
  busy[source] = nil
  if not ok then
    print("[bzhar_makeup] save failed: " .. tostring(err))
    TriggerClientEvent("bzhar_makeup:saveResult", source, false, "save_failed")
  end
end)

local function sendLook(source)
  CreateThread(function()
    local character = nil
    for _ = 1, CHARACTER_TRIES do
      character = usedCharacter(source)
      if character then break end
      Wait(1000)
    end
    if not character then
      dprint("no character for player", source, "after waiting")
      return
    end
    TriggerClientEvent("bzhar_makeup:setLook", source, loadLook(character.charIdentifier))
    dprint("sent look for character", character.charIdentifier)
  end)
end

local function sendLooks(source)
  CreateThread(function()
    local characters = nil
    for _ = 1, CHARACTER_TRIES do
      local user = Core.getUser(source)
      characters = user and user.getUserCharacters
      if characters and next(characters) then break end
      characters = nil
      Wait(1000)
    end
    if not characters then
      dprint("no characters for player", source, "after waiting")
      return
    end
    local looks = {}
    local count = 0
    for _, character in pairs(characters) do
      local id = character and tonumber(character.charIdentifier)
      if id then
        looks[tostring(id)] = loadLook(id)
        count = count + 1
      end
    end
    TriggerClientEvent("bzhar_makeup:setLooks", source, looks)
    dprint("sent", count, "looks to player", source)
  end)
end

AddEventHandler("vorp:SelectedCharacter", function(playerSource)
  sendLook(playerSource)
end)

RegisterNetEvent("bzhar_makeup:requestLook", function()
  sendLook(source)
end)

RegisterNetEvent("bzhar_makeup:requestLooks", function()
  sendLooks(source)
end)

RegisterNetEvent("vorpcharacter:reloadedskinlistener", function()
  sendLook(source)
end)

AddEventHandler("playerDropped", function()
  busy[source] = nil
end)

CreateThread(function()
  local ok, err = pcall(function()
    MySQL.query.await([[
      CREATE TABLE IF NOT EXISTS `bzhar_makeup` (
        `charidentifier` INT(11) NOT NULL,
        `layers` LONGTEXT NOT NULL,
        PRIMARY KEY (`charidentifier`)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
  end)
  if ok then
    dprint("table ready")
  else
    print("[bzhar_makeup] database setup failed: " .. tostring(err))
  end
end)
