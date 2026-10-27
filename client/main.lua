local PROMPT_GROUP = "bzhar_makeup"
local MENU_PROMPT_GROUP = "bzhar_makeup_menu"
local PROMPT_RANGE = 20.0
local DEFAULT_RADIUS = 1.5
local SEAT_TYPES = { "PROP_PLAYER_BARBER_SEAT" }
local SEAT_SEARCH_RADIUS = 4.0
local SEAT_SEARCH_MAX = 32
local SIT_HEAD_START = 900
local SIT_TIMEOUT = 12000
local SIT_STILL_CHECKS = 6
local STAND_TIMEOUT = 4000
local CAMERA_BLEND = 800
local HEAD_BONE = "SKEL_Head"
local HEAD_FALLBACK_HEIGHT = 1.55
local ROTATE_SPEED = 1.2
local ROTATE_LEFT = "INPUT_COVER"
local ROTATE_RIGHT = "INPUT_RELOAD"
local SELECT_KEY = "INPUT_FRONTEND_ACCEPT"
local BACK_KEY = "INPUT_FRONTEND_CANCEL"
local SAVE_TIMEOUT = 10000
local WATCHDOG_INTERVAL = 2000
local BLOCKED_CONTROLS = {
  "INPUT_MOVE_LR", "INPUT_MOVE_UD", "INPUT_MOVE_UP_ONLY", "INPUT_MOVE_DOWN_ONLY",
  "INPUT_MOVE_LEFT_ONLY", "INPUT_MOVE_RIGHT_ONLY", "INPUT_SPRINT", "INPUT_JUMP",
  "INPUT_DUCK", "INPUT_ENTER", "INPUT_ATTACK", "INPUT_AIM",
}

local menuOpen = false
local seated = false
local saving = false
local cam = nil
local camAngle = 0.0
local blips = {}
local seatHashes = {}
local blockedHashes = {}
local rotateLeftHash = 0
local rotateRightHash = 0

local function dprint(...)
  if Config.Debug then print("[bzhar_makeup]", ...) end
end

function IsMakeupMenuOpen()
  return menuOpen
end

local function sameHash(a, b)
  if math.type(a) ~= "integer" or math.type(b) ~= "integer" then return false end
  return (a & 0xFFFFFFFF) == (b & 0xFFFFFFFF)
end

local function controlHeld(hash)
  return IsControlPressed(0, hash) or IsDisabledControlPressed(0, hash)
end

local function requestLook()
  TriggerServerEvent("bzhar_makeup:requestLook")
end

local function createBlips()
  if not Config.Blip.enable then return end
  for i = 1, #Config.Locations do
    local coords = Config.Locations[i].coords
    local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, coords.x, coords.y, coords.z)
    SetBlipSprite(blip, GetHashFromString(Config.Blip.sprite), true)
    SetBlipScale(blip, Config.Blip.scale + 0.0)
    Citizen.InvokeNative(0x9CB1A1623062F402, blip, T("blip_name"))
    blips[#blips + 1] = blip
  end
end

local function addCommandSuggestion()
  if not Config.RefreshCommand then return end
  TriggerEvent("chat:addSuggestion", "/" .. Config.RefreshCommand, T("cmd_refresh"), {})
end

local function isBarberSeat(scenario)
  if not Citizen.InvokeNative(0x841475AC96E794D1, scenario) then return false end
  local typeHash = Citizen.InvokeNative(0xA92450B5AE687AAF, scenario, Citizen.ResultAsInteger())
  for i = 1, #seatHashes do
    if sameHash(typeHash, seatHashes[i]) then return true end
  end
  return false
end

local function seatDistance(scenario, origin)
  local coords = Citizen.InvokeNative(0xA8452DD321607029, scenario, true, Citizen.ResultAsVector())
  if not coords or (coords.x == 0.0 and coords.y == 0.0) then return SEAT_SEARCH_RADIUS end
  return #(coords - origin)
end

local function scanForSeat(center, origin)
  local buffer = DataView.ArrayBuffer(8 * (SEAT_SEARCH_MAX + 2))
  Citizen.InvokeNative(0x345EC3B7EBDE1CB5, center.x, center.y, center.z, SEAT_SEARCH_RADIUS, buffer:Buffer(), SEAT_SEARCH_MAX)
  local best, bestDistance = nil, math.huge
  for slot = 0, SEAT_SEARCH_MAX do
    local scenario = buffer:GetInt32(slot * 8)
    if scenario ~= 0 and isBarberSeat(scenario) then
      local distance = seatDistance(scenario, origin)
      if distance < bestDistance then
        best, bestDistance = scenario, distance
      end
    end
  end
  return best, bestDistance
end

local function findSeat(location)
  local origin = GetEntityCoords(PlayerPedId())
  local seat, distance = scanForSeat(origin, origin)
  if location then
    local other, otherDistance = scanForSeat(location.coords, origin)
    if other and otherDistance < distance then seat = other end
  end
  return seat
end

local function sitOnChair(location)
  local ped = PlayerPedId()
  local seat = findSeat(location)
  Citizen.InvokeNative(0xFCCC886EDE3C63EC, ped, 2, true)
  if seat then
    ClearPedTasksImmediately(ped, false, false)
    TaskUseScenarioPoint(ped, seat, "", -1.0, true, false, 0, false, -1.0, true)
    dprint("sitting on barber seat", seat)
  elseif location then
    local coords = location.coords
    Citizen.InvokeNative(0x322BFDEA666E2B0E, ped, coords.x, coords.y, coords.z, location.radius or DEFAULT_RADIUS, -1, true, true, true, true)
    dprint("no barber seat found, using the nearest seat at the shop")
  else
    return false
  end
  seated = true
  return true
end

local function waitUntilSeated()
  local ped = PlayerPedId()
  Wait(SIT_HEAD_START)
  local waited, still = SIT_HEAD_START, 0
  while waited < SIT_TIMEOUT do
    if IsPedDeadOrDying(ped, true) then return false end
    if IsPedUsingAnyScenario(ped) and GetEntitySpeed(ped) < 0.05 then
      still = still + 1
      if still >= SIT_STILL_CHECKS then return true end
    else
      still = 0
    end
    Wait(100)
    waited = waited + 100
  end
  dprint("the player did not sit down in time")
  return IsPedUsingAnyScenario(ped) and true or false
end

local function standUp(now)
  if not seated then return end
  seated = false
  local ped = PlayerPedId()
  FreezeEntityPosition(ped, false)
  if now then
    ClearPedTasksImmediately(ped, false, false)
    return
  end
  ClearPedTasks(ped, false, false)
  CreateThread(function()
    local waited = 0
    while waited < STAND_TIMEOUT do
      Wait(100)
      waited = waited + 100
      if menuOpen or seated or not IsPedUsingAnyScenario(ped) then return end
    end
    dprint("the player was still seated, forcing the stand up")
    FreezeEntityPosition(ped, false)
    ClearPedTasksImmediately(ped, false, false)
  end)
end

local function getFaceCoords(ped)
  local boneIndex = GetEntityBoneIndexByName(ped, HEAD_BONE)
  if boneIndex and boneIndex ~= -1 then
    local bone = GetWorldPositionOfEntityBone(ped, boneIndex)
    if bone and bone.z ~= 0.0 then return bone end
  end
  local coords = GetEntityCoords(ped)
  return vector3(coords.x, coords.y, coords.z + HEAD_FALLBACK_HEIGHT)
end

local function updateCamera()
  if not cam then return end
  local ped = PlayerPedId()
  local face = getFaceCoords(ped)
  local angle = math.rad(GetEntityHeading(ped) + camAngle)
  local distance = Config.Camera.distance + 0.0
  SetCamCoord(cam, face.x - math.sin(angle) * distance, face.y + math.cos(angle) * distance, face.z + Config.Camera.height)
  PointCamAtCoord(cam, face.x, face.y, face.z)
end

local function startCamera()
  camAngle = 0.0
  cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
  SetCamFov(cam, Config.Camera.fov + 0.0)
  updateCamera()
  SetCamActive(cam, true)
  RenderScriptCams(true, true, CAMERA_BLEND, true, true, 0)
end

local function stopCamera()
  if not cam then return end
  RenderScriptCams(false, true, CAMERA_BLEND, true, true, 0)
  SetCamActive(cam, false)
  DestroyCam(cam, false)
  cam = nil
end

local function menuLoop()
  CreateThread(function()
    while menuOpen do
      if IsPedDeadOrDying(PlayerPedId(), true) then
        CloseMakeupMenu(false)
        break
      end
      for i = 1, #blockedHashes do
        DisableControlAction(0, blockedHashes[i], true)
      end
      jo.prompt.displayGroup(MENU_PROMPT_GROUP, T("prompt_group"))
      if controlHeld(rotateLeftHash) then
        camAngle = (camAngle + ROTATE_SPEED) % 360.0
      elseif controlHeld(rotateRightHash) then
        camAngle = (camAngle - ROTATE_SPEED) % 360.0
      end
      updateCamera()
      Wait(0)
    end
  end)
end

function OpenMakeupMenu(location)
  if menuOpen then return end
  menuOpen = true
  saving = false
  Draft = CopyLook(Look)
  if Config.SitInChair and sitOnChair(location) then
    if waitUntilSeated() then
      FreezeEntityPosition(PlayerPedId(), true)
    end
  end
  if IsPedDeadOrDying(PlayerPedId(), true) then
    CloseMakeupMenu(false)
    return
  end
  local ok, err = pcall(function()
    startCamera()
    BuildMakeupMenus()
    OpenRootMenu()
  end)
  if not ok then
    print("[bzhar_makeup] the menu could not open: " .. tostring(err))
    CloseMakeupMenu(false)
    return
  end
  menuLoop()
end

function CloseMakeupMenu(keepLook)
  if not menuOpen then return end
  menuOpen = false
  saving = false
  jo.menu.show(false)
  stopCamera()
  standUp(false)
  if keepLook then
    Look = CopyLook(Draft)
  else
    Draft = CopyLook(Look)
    RestoreLook()
  end
end

function SaveMakeup()
  if saving then return end
  if LooksAreEqual(Draft, Look) then
    jo.notif.rightSuccess(T("nothing_changed"))
    CloseMakeupMenu(false)
    return
  end
  local payload = {}
  for key, entry in pairs(Draft) do
    if Makeup.IsValidStyle(key, entry.style) and entry.style > 1 then
      payload[key] = {
        style = entry.style,
        tint = entry.tint or Makeup.DefaultTint,
        opacity = entry.opacity or 1.0,
      }
    end
  end
  saving = true
  TriggerServerEvent("bzhar_makeup:save", payload)
  SetTimeout(SAVE_TIMEOUT, function()
    saving = false
  end)
end

RegisterNetEvent("bzhar_makeup:saveResult", function(success, reason)
  saving = false
  if not menuOpen then
    if success then requestLook() end
    return
  end
  if success then
    jo.notif.rightSuccess(T("saved"))
    CloseMakeupMenu(true)
  else
    jo.notif.rightError(T(reason or "no_money"))
  end
end)

CreateThread(function()
  rotateLeftHash = GetHashFromString(ROTATE_LEFT)
  rotateRightHash = GetHashFromString(ROTATE_RIGHT)
  for i = 1, #SEAT_TYPES do
    seatHashes[#seatHashes + 1] = GetHashFromString(SEAT_TYPES[i])
  end
  for i = 1, #BLOCKED_CONTROLS do
    blockedHashes[#blockedHashes + 1] = GetHashFromString(BLOCKED_CONTROLS[i])
  end
  jo.prompt.create(PROMPT_GROUP, T("open_prompt"), Config.OpenKey, false)
  jo.prompt.create(MENU_PROMPT_GROUP, T("rotate"), { ROTATE_LEFT, ROTATE_RIGHT }, false)
  jo.prompt.create(MENU_PROMPT_GROUP, T("select"), SELECT_KEY, false)
  jo.prompt.create(MENU_PROMPT_GROUP, T("back"), BACK_KEY, false)
  createBlips()
  addCommandSuggestion()
  TriggerServerEvent("bzhar_makeup:requestLooks")
  requestLook()
  while true do
    local sleep = 1000
    if not menuOpen then
      local ped = PlayerPedId()
      local coords = GetEntityCoords(ped)
      for i = 1, #Config.Locations do
        local location = Config.Locations[i]
        local distance = #(coords - location.coords)
        if distance < PROMPT_RANGE then
          sleep = 0
          if distance < (location.radius or DEFAULT_RADIUS) and not IsPedDeadOrDying(ped, true) then
            jo.prompt.displayGroup(PROMPT_GROUP, T("prompt_group"))
            if jo.prompt.isCompleted(PROMPT_GROUP, Config.OpenKey) then
              OpenMakeupMenu(location)
            end
          end
          break
        end
      end
    end
    Wait(sleep)
  end
end)

RegisterNetEvent("vorp:SelectedCharacter", function()
  requestLook()
end)

AddEventHandler("vorp:initCharacter", function()
  requestLook()
end)

RegisterNetEvent("vorpcharacter:selectCharacter", function()
  TriggerServerEvent("bzhar_makeup:requestLooks")
end)

CreateThread(function()
  local lastPed = PlayerPedId()
  local lastModel = GetEntityModel(lastPed)
  while true do
    Wait(WATCHDOG_INTERVAL)
    local ped = PlayerPedId()
    local model = GetEntityModel(ped)
    if ped ~= lastPed or model ~= lastModel then
      lastPed = ped
      lastModel = model
      if not menuOpen then
        dprint("ped changed, putting the makeup back on")
        WearSavedLook("ped changed")
        requestLook()
      end
    end
  end
end)

if Config.RefreshCommand then
  RegisterCommand(Config.RefreshCommand, function()
    if menuOpen then return end
    requestLook()
    WearSavedLook("command")
  end, false)
end

AddEventHandler("onClientResourceStart", function(resource)
  if resource == "chat" then addCommandSuggestion() end
end)

AddEventHandler("onResourceStop", function(resource)
  if resource ~= GetCurrentResourceName() then return end
  stopCamera()
  standUp(true)
  for i = 1, #blips do
    RemoveBlip(blips[i])
  end
  if Config.RefreshCommand then
    TriggerEvent("chat:removeSuggestion", "/" .. Config.RefreshCommand)
  end
end)
