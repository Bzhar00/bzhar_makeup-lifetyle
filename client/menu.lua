local ROOT = "bzhar_makeup"
local MENU_MAKEUP = "bzhar_makeup:makeup"
local MENU_LIFESTYLE = "bzhar_makeup:lifestyle"
local OPACITY_STEP = 5
local TICK_ICON = "tick"
local ICONS = {
  makeup     = "makeup",
  lifestyle  = "lifestyle",
  reset      = "cross",
  save       = "save",
  lipstick   = "makeup",
  blush      = "paint",
  eyeshadow  = "palette",
  eyeliner   = "pencil",
  foundation = "clean_shaven",
  complex    = "lifestyle",
  ageing     = "lifestyle",
  freckles   = "star",
  moles      = "star",
  acne       = "lifestyle",
  disc       = "palette",
  spots      = "star",
  scar       = "warning",
  grime      = "lifestyle",
}

local saveItemIndex = nil
local opacityLabels = {}
local opacityValues = {}

local function buildOpacityList()
  opacityLabels = {}
  opacityValues = {}
  for percent = 0, 100, OPACITY_STEP do
    opacityValues[#opacityValues + 1] = percent
    opacityLabels[#opacityLabels + 1] = { label = percent .. "%" }
  end
  if opacityValues[#opacityValues] ~= 100 then
    opacityValues[#opacityValues + 1] = 100
    opacityLabels[#opacityLabels + 1] = { label = "100%" }
  end
end

local function opacityToIndex(opacity)
  local wanted = math.floor(((opacity or 1.0) * 100) + 0.5)
  local best, bestDiff = #opacityValues, math.huge
  for i = 1, #opacityValues do
    local diff = math.abs(opacityValues[i] - wanted)
    if diff < bestDiff then
      best, bestDiff = i, diff
    end
  end
  return best
end

local function indexToOpacity(index)
  return (opacityValues[index] or 100) / 100.0
end

local function priceTable(amount)
  if not amount or amount <= 0 then return { money = 0 } end
  if Config.Currency == 1 then return { gold = amount } end
  return { money = amount }
end

local function iconFor(key)
  return ICONS[key]
end

local function categoryMenuId(key)
  return "bzhar_makeup:cat:" .. key
end

local function groupMenuId(group)
  if group == "makeup" then return MENU_MAKEUP end
  return MENU_LIFESTYLE
end

local function refreshSaveTotal()
  if not saveItemIndex or not jo.menu.isExist(ROOT) then return end
  local menu = jo.menu.get(ROOT)
  if not menu then return end
  menu:updateValue({ "items", saveItemIndex, "price" }, priceTable(Makeup.GetTotal(Draft, Look)))
  menu:push()
end

local function markChosenStyle(key, index)
  local id = categoryMenuId(key)
  if not jo.menu.isExist(id) then return end
  local menu = jo.menu.get(id)
  if not menu or not menu.items then return end
  for i = 1, #menu.items do
    if i == index then
      menu:updateValue({ "items", i, "iconRight" }, TICK_ICON)
    elseif menu.items[i].iconRight then
      menu:deleteValue({ "items", i, "iconRight" })
    end
  end
  menu:push()
end

local function markUsedSection(key)
  local category = Makeup.GetCategory(key)
  if not category then return end
  local id = groupMenuId(category.group)
  if not jo.menu.isExist(id) then return end
  local menu = jo.menu.get(id)
  if not menu or not menu.items then return end
  for i = 1, #menu.items do
    local item = menu.items[i]
    if item.data and item.data.category == key then
      local entry = Draft[key]
      if entry and (entry.style or 1) > 1 then
        menu:updateValue({ "items", i, "iconRight" }, TICK_ICON)
      elseif item.iconRight then
        menu:deleteValue({ "items", i, "iconRight" })
      end
    end
  end
  menu:push()
end

local function readRowValues(key, item)
  local entry = Draft[key]
  local tint = entry and entry.tint or Makeup.DefaultTint
  local opacity = entry and entry.opacity or 1.0
  local sliders = item and item.sliders or {}
  for i = 1, #sliders do
    local slider = sliders[i]
    if slider.type == "palette" then
      tint = tonumber(slider.current) or tint
    else
      opacity = indexToOpacity(slider.current or #opacityValues)
    end
  end
  return tint, opacity
end

local function previewStyle(key, index, item)
  local tint, opacity = readRowValues(key, item)
  ApplyLayer(key, { style = index, tint = tint, opacity = opacity })
end

local function chooseStyle(key, index, item)
  local tint, opacity = readRowValues(key, item)
  local entry = GetDraftEntry(key)
  entry.style = index
  entry.tint = tint
  entry.opacity = opacity
  ApplyLayer(key, entry)
  markChosenStyle(key, index)
  markUsedSection(key)
  refreshSaveTotal()
end

local function buildCategoryMenu(category)
  local key = category.key
  local id = categoryMenuId(key)
  local chosen = GetDraftEntry(key)
  local chosenIndex = chosen.style or 1
  if chosenIndex < 1 or chosenIndex > #category.styles then chosenIndex = 1 end
  local menu = jo.menu.create(id, {
    type = "list",
    title = T("title"),
    subtitle = T("cat_" .. key),
    onExit = function()
      ApplyLayer(key, Draft[key])
    end,
  })
  for index = 1, #category.styles do
    local style = category.styles[index]
    local item = {
      title = TStyle(key, style.label),
      icon = iconFor(key),
      data = { category = key, style = index },
      sliders = {},
    }
    if index == chosenIndex then
      item.iconRight = TICK_ICON
    end
    if not style.none then
      item.price = priceTable(Makeup.GetPrice(key))
      item.priceTitle = T("price_label")
      if category.tintable then
        item.sliders[#item.sliders + 1] = {
          type = "palette",
          title = T("colour"),
          tint = Makeup.PaletteStrip,
          current = chosen.tint or Makeup.DefaultTint,
          min = 0,
          max = #Makeup.Colorways - 1,
        }
      end
      item.sliders[#item.sliders + 1] = {
        title = T("opacity"),
        values = opacityLabels,
        current = opacityToIndex(chosen.opacity),
      }
    end
    item.onActive = function(data)
      previewStyle(key, index, data and data.item)
    end
    item.onChange = function(data)
      previewStyle(key, index, data and data.item)
    end
    item.onClick = function(data)
      chooseStyle(key, index, data and data.item)
    end
    menu:addItem(item)
  end
  menu:send()
  menu:setCurrentIndex(chosenIndex)
end

local function buildGroupMenu(id, group, subtitle)
  local menu = jo.menu.create(id, {
    type = "list",
    title = T("title"),
    subtitle = subtitle,
  })
  local list = Makeup.GetGroup(group)
  for i = 1, #list do
    local category = list[i]
    buildCategoryMenu(category)
    local item = {
      title = T("cat_" .. category.key),
      icon = iconFor(category.key),
      child = categoryMenuId(category.key),
      price = priceTable(Makeup.GetPrice(category.key)),
      priceTitle = T("price_label"),
      data = { category = category.key },
    }
    local entry = Draft[category.key]
    if entry and (entry.style or 1) > 1 then
      item.iconRight = TICK_ICON
    end
    menu:addItem(item)
  end
  menu:send()
end

local function buildSubMenus()
  buildOpacityList()
  if Config.ShowMakeup then
    buildGroupMenu(MENU_MAKEUP, "makeup", T("menu_makeup"))
  end
  if Config.ShowLifestyle then
    buildGroupMenu(MENU_LIFESTYLE, "lifestyle", T("menu_lifestyle"))
  end
end

local function buildRootMenu()
  local menu = jo.menu.create(ROOT, {
    type = "list",
    title = T("title"),
    subtitle = T("menu_root_sub"),
    onBack = function()
      CloseMakeupMenu(false)
    end,
  })
  if Config.ShowMakeup then
    menu:addItem({
      title = T("menu_makeup"),
      description = T("makeup_desc"),
      icon = iconFor("makeup"),
      child = MENU_MAKEUP,
    })
  end
  if Config.ShowLifestyle then
    menu:addItem({
      title = T("menu_lifestyle"),
      description = T("lifestyle_desc"),
      icon = iconFor("lifestyle"),
      child = MENU_LIFESTYLE,
    })
  end
  menu:addItem({
    title = T("reset"),
    description = T("reset_desc"),
    icon = iconFor("reset"),
    onClick = function()
      Draft = {}
      ClearLook()
      buildSubMenus()
      refreshSaveTotal()
      jo.notif.rightSuccess(T("removed"))
    end,
  })
  menu:addItem({
    title = T("save"),
    description = T("save_desc"),
    icon = iconFor("save"),
    price = priceTable(Makeup.GetTotal(Draft, Look)),
    priceTitle = T("total"),
    onClick = function()
      SaveMakeup()
    end,
  })
  saveItemIndex = #menu.items
  menu:send()
end

function BuildMakeupMenus()
  buildSubMenus()
  buildRootMenu()
end

function OpenRootMenu()
  jo.menu.setCurrentMenu(ROOT, false, true)
  jo.menu.show(true)
end
