Look = {}
Draft = {}
SelectionLooks = {}
SelectionReady = false

local HEADS = "heads"
local LOAD_SCREEN_TIMEOUT = 8000
local LOAD_GIVE_UP = 38000
local LOAD_PASSES = 3
local LOAD_PASS_GAP = 2500
local APPLY_TIMEOUT = 6000
local SELECTION_SCREEN_WAIT = 6000
local SELECTION_DATA_WAIT = 5000
local CLONE_PASSES = 3
local CLONE_PASS_GAP = 700
local TEXTURE_WAIT = 2000
local DRAW_ORDER = {
  "ageing", "scar", "acne", "moles", "disc", "freckles", "complex", "spots",
  "foundation", "blush", "eyeshadow", "eyeliner", "lipstick", "grime",
}
local NO_COLOUR = {
  scar = true, spots = true, disc = true, complex = true,
  acne = true, ageing = true, moles = true, freckles = true,
}

local function dprint(...)
  if Config.Debug then print("[bzhar_makeup]", ...) end
end

function CopyLook(source)
  local copy = {}
  for key, entry in pairs(source or {}) do
    copy[key] = { style = entry.style, tint = entry.tint, opacity = entry.opacity }
  end
  return copy
end

local function activeStyle(key, entry)
  if not entry or not entry.style then return nil end
  local category = Makeup.GetCategory(key)
  if not category then return nil end
  local style = category.styles[entry.style]
  if not style or style.none then return nil end
  return style
end

function LookHasLayers(look)
  for i = 1, #Makeup.Categories do
    local key = Makeup.Categories[i].key
    if activeStyle(key, look and look[key]) then return true end
  end
  return false
end

local function activeKeys(look)
  local keys = {}
  for i = 1, #DRAW_ORDER do
    local key = DRAW_ORDER[i]
    if activeStyle(key, look and look[key]) then keys[#keys + 1] = key end
  end
  return keys
end

function ApplyLayerToPed(ped, layerName, entry)
  if not ped or ped == 0 or not DoesEntityExist(ped) then return end
  local category = Makeup.GetCategory(layerName)
  if not category then return end
  local style = activeStyle(layerName, entry)
  if not style then
    jo.pedTexture.remove(ped, layerName)
    return
  end
  local data = {
    id = style.id or 0,
    sheetGrid = style.sheetGrid or 0,
    opacity = (entry.opacity or 1.0) + 0.0,
  }
  if category.tintable then
    local tint = entry.tint or Makeup.DefaultTint
    data.palette = Makeup.Palette
    data.tint0, data.tint1, data.tint2 = tint, tint, tint
  end
  jo.pedTexture.apply(ped, layerName, data)
end

function ApplyLookToPed(ped, look)
  for i = 1, #Makeup.Categories do
    local key = Makeup.Categories[i].key
    ApplyLayerToPed(ped, key, look and look[key] or nil)
  end
end

function ApplyLayer(layerName, entry)
  ApplyLayerToPed(PlayerPedId(), layerName, entry)
end

function ApplyLook(look)
  ApplyLookToPed(PlayerPedId(), look)
end

function ClearLook()
  local ped = PlayerPedId()
  for i = 1, #Makeup.Categories do
    jo.pedTexture.remove(ped, Makeup.Categories[i].key)
  end
end

function RestoreLook()
  ApplyLook(Look)
end

function GetDraftEntry(layerName)
  if not Draft[layerName] then
    Draft[layerName] = { style = 1, tint = Makeup.DefaultTint, opacity = 1.0 }
  end
  return Draft[layerName]
end

function LooksAreEqual(a, b)
  return Makeup.LooksEqual(a, b)
end

local function RequestTexture(albedo, normal, material)
  return Citizen.InvokeNative(0xC5E7204F322E49EB, albedo, normal, material, Citizen.ResultAsInteger())
end

local function AddTextureLayer(textureId, albedo, normal, material, blendType, alpha, sheetGrid)
  return Citizen.InvokeNative(0x86BB5FF45F193A02, textureId, albedo, normal, material, blendType, alpha, sheetGrid, Citizen.ResultAsInteger())
end

local function GetNumComponentsInPed(ped)
  return Citizen.InvokeNative(0x90403E8107B60E81, ped, Citizen.ResultAsInteger())
end

local function GetCategoryOfComponentAtIndex(ped, index)
  return Citizen.InvokeNative(0x9B90842304C938A7, ped, index, 0, Citizen.ResultAsInteger())
end

local function GetMetaPedAssetGuids(ped, index)
  return Citizen.InvokeNative(0xA9C28516A6DC9D56, ped, index,
    Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt())
end

local function IsTextureValid(textureId)
  return Citizen.InvokeNative(0x31DC8D3F216D8509, textureId)
end

local function ReleaseTexture(textureId)
  Citizen.InvokeNative(0x6BEFAA907B076859, textureId)
end

local function ApplyTextureOnPed(ped, component, textureId)
  Citizen.InvokeNative(0x0B46E25761519058, ped, component, textureId)
end

local function SetTextureLayerPallete(textureId, layer, palette)
  Citizen.InvokeNative(0x1ED8588524AC9BE1, textureId, layer, palette)
end

local function SetTextureLayerTint(textureId, layer, tint0, tint1, tint2)
  Citizen.InvokeNative(0x2DF59FFE6FFD6044, textureId, layer, tint0, tint1, tint2)
end

local function SetTextureLayerSheetGrid(textureId, layer, sheetGrid)
  Citizen.InvokeNative(0x3329AAE2882FC8E4, textureId, layer, sheetGrid)
end

local function SetTextureLayerAlpha(textureId, layer, alpha)
  Citizen.InvokeNative(0x6C76BC24F8BB709A, textureId, layer, alpha)
end

local function UpdatePedTexture(textureId)
  Citizen.InvokeNative(0x92DAABA2C1C10B0E, textureId)
end

local function UpdatePedVariation(ped)
  Citizen.InvokeNative(0x704C908E9C405136, ped)
  Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false)
end

local function headComponentIndex(ped)
  local wanted = GetHashFromString(HEADS)
  local count = GetNumComponentsInPed(ped) or 0
  for i = 0, count - 1 do
    if GetCategoryOfComponentAtIndex(ped, i) == wanted then return i end
  end
  return nil
end

local function waitTexture(textureId)
  local waited = 0
  while not IsTextureValid(textureId) and waited < TEXTURE_WAIT do
    Wait(50)
    waited = waited + 50
  end
  return IsTextureValid(textureId)
end

local function RawApplyToPed(ped, look)
  local index = headComponentIndex(ped)
  if not index then
    dprint("no head component on ped", ped)
    return false
  end
  local _, albedo, normal, material = GetMetaPedAssetGuids(ped, index)
  if not albedo or albedo == 0 then
    dprint("no head texture on ped", ped)
    return false
  end
  local textureId = RequestTexture(albedo, normal, material)
  if not textureId or textureId < 0 then
    dprint("the game did not give a texture for ped", ped)
    return false
  end
  if not waitTexture(textureId) then
    ReleaseTexture(textureId)
    dprint("the texture never became ready for ped", ped)
    return false
  end
  for i = 1, #DRAW_ORDER do
    local key = DRAW_ORDER[i]
    local entry = look and look[key]
    local style = activeStyle(key, entry)
    if style then
      local category = Makeup.GetCategory(key)
      local name = ("mp_u_faov_%s_%03d"):format(key, style.id or 0)
      local blend = NO_COLOUR[key] and 1 or 0
      local opacity = (entry.opacity or 1.0) + 0.0
      local sheetGrid = style.sheetGrid or 0
      local layer = AddTextureLayer(textureId,
        GetHashFromString(name), GetHashFromString(name .. "_nm"), GetHashFromString(name .. "_ab"),
        blend, opacity, sheetGrid)
      if blend == 0 and category.tintable then
        local tint = entry.tint or Makeup.DefaultTint
        SetTextureLayerPallete(textureId, layer, GetHashFromString(Makeup.Palette))
        SetTextureLayerTint(textureId, layer, tint, tint, tint)
      end
      SetTextureLayerSheetGrid(textureId, layer, sheetGrid)
      SetTextureLayerAlpha(textureId, layer, opacity)
    end
  end
  Wait(0)
  if not IsTextureValid(textureId) then
    ReleaseTexture(textureId)
    dprint("the texture went bad after the layers were added, ped", ped)
    return false
  end
  ApplyTextureOnPed(ped, GetHashFromString(HEADS), textureId)
  UpdatePedTexture(textureId)
  UpdatePedVariation(ped)
  ReleaseTexture(textureId)
  dprint("face rebuilt without jo_libs on ped", ped)
  return true
end

local function layersLanded(ped, keys)
  local state = Entity(ped).state["jo_pedTexture"]
  if type(state) ~= "table" then return false end
  local head = state[HEADS]
  if type(head) ~= "table" or type(head.layers) ~= "table" then return false end
  for i = 1, #keys do
    if not head.layers[keys[i]] then return false end
  end
  return true
end

function ApplyLookAndWait(ped, look, timeout)
  if not ped or ped == 0 or not DoesEntityExist(ped) then return false end
  local keys = activeKeys(look)
  if not NetworkGetEntityIsNetworked(ped) then
    return RawApplyToPed(ped, look)
  end
  Entity(ped).state:set("jo_pedTexture", nil, false)
  ApplyLookToPed(ped, look)
  if #keys == 0 then return true end
  local passed = 0
  timeout = timeout or APPLY_TIMEOUT
  while passed < timeout do
    if not DoesEntityExist(ped) then return false end
    if layersLanded(ped, keys) then return true end
    Wait(100)
    passed = passed + 100
  end
  return RawApplyToPed(ped, look)
end

local generation = 0
local wornOnPed = nil

local function pedIsReady(ped)
  return ped ~= nil and ped ~= 0 and DoesEntityExist(ped) and IsPedReadyToRender(ped)
end

local function waitForLoad(myGeneration)
  local waited = 0
  while generation == myGeneration and waited < LOAD_GIVE_UP do
    if pedIsReady(PlayerPedId()) then
      if not IsScreenFadedOut() and not IsLoadingScreenVisible() then return true end
      if waited >= LOAD_SCREEN_TIMEOUT then
        dprint("screen still black, putting the makeup on anyway")
        return true
      end
    end
    Wait(200)
    waited = waited + 200
  end
  return false
end

function WearSavedLook(reason)
  generation = generation + 1
  local myGeneration = generation
  CreateThread(function()
    if not waitForLoad(myGeneration) then return end
    local hasLayers = LookHasLayers(Look)
    local ped = PlayerPedId()
    if not hasLayers and wornOnPed ~= ped then
      dprint("no makeup to put back", reason)
      return
    end
    for pass = 1, LOAD_PASSES do
      if generation ~= myGeneration then return end
      ped = PlayerPedId()
      if not pedIsReady(ped) then return end
      local ok = ApplyLookAndWait(ped, Look, APPLY_TIMEOUT)
      wornOnPed = hasLayers and ped or nil
      dprint("pass", pass, "of", LOAD_PASSES, ok and "done" or "failed", reason or "")
      if pass < LOAD_PASSES then Wait(LOAD_PASS_GAP) end
    end
  end)
end

RegisterNetEvent("bzhar_makeup:setLook", function(look)
  Look = Makeup.CleanLook(look)
  if IsMakeupMenuOpen and IsMakeupMenuOpen() then return end
  Draft = CopyLook(Look)
  WearSavedLook("look received")
end)

RegisterNetEvent("bzhar_makeup:setLooks", function(looks)
  SelectionLooks = {}
  local count = 0
  for charId, look in pairs(looks or {}) do
    SelectionLooks[tonumber(charId) or charId] = Makeup.CleanLook(look)
    count = count + 1
  end
  SelectionReady = true
  dprint("selection looks received for", count, "characters")
end)

local function paintLocalPed(ped, look)
  CreateThread(function()
    for pass = 1, CLONE_PASSES do
      if not DoesEntityExist(ped) then return end
      local ok = RawApplyToPed(ped, look)
      dprint("clone pass", pass, ok and "done" or "failed", "ped", ped)
      if pass < CLONE_PASSES then Wait(CLONE_PASS_GAP) end
    end
  end)
end

exports("applyToPed", function(ped, charIdentifier)
  local id = tonumber(charIdentifier) or charIdentifier
  if not ped or ped == 0 or not DoesEntityExist(ped) then
    dprint("selection screen: no ped for character", tostring(id))
    return false
  end
  local waited = 0
  while not SelectionReady and waited < SELECTION_DATA_WAIT do
    Wait(100)
    waited = waited + 100
  end
  if not SelectionReady then
    dprint("selection screen: the server has not sent the saved looks yet")
    return false
  end
  local look = SelectionLooks[id]
  if not look then
    dprint("selection screen: no saved look for character", tostring(id))
    return false
  end
  if not LookHasLayers(look) then
    dprint("selection screen: character", tostring(id), "wears no makeup")
    return false
  end
  waited = 0
  while not IsPedReadyToRender(ped) and waited < 1000 do
    Wait(50)
    waited = waited + 50
  end
  if not NetworkGetEntityIsNetworked(ped) then
    dprint("selection screen: ped", ped, "is a clone, painting it in the background")
    paintLocalPed(ped, look)
    return true
  end
  local ok = ApplyLookAndWait(ped, look, SELECTION_SCREEN_WAIT)
  dprint("selection screen: ped", ped, "character", tostring(id), ok and "done" or "failed")
  return ok
end)

exports("refresh", function()
  WearSavedLook("refresh export")
end)

exports("getLook", function()
  return CopyLook(Look)
end)

AddEventHandler("onClientResourceStart", function(resource)
  if resource ~= GetCurrentResourceName() then return end
  dprint("client ready, exports: applyToPed, refresh, getLook")
end)
