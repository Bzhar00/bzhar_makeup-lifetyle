Makeup = {}

Makeup.Colorways = {
  { tint = 0, hex = "#8E1220" },
  { tint = 1, hex = "#BE264C" },
  { tint = 2, hex = "#B23D59" },
  { tint = 3, hex = "#AB4E67" },
  { tint = 4, hex = "#993F58" },
  { tint = 5, hex = "#A42F39" },
  { tint = 6, hex = "#701F21" },
  { tint = 7, hex = "#9C574D" },
  { tint = 8, hex = "#B77A6A" },
  { tint = 9, hex = "#BF9185" },
  { tint = 10, hex = "#BB807E" },
  { tint = 11, hex = "#9F5F50" },
  { tint = 12, hex = "#A5503D" },
  { tint = 13, hex = "#9F3F26" },
  { tint = 14, hex = "#A76066" },
  { tint = 15, hex = "#C27689" },
  { tint = 16, hex = "#E589AE" },
  { tint = 17, hex = "#E0679A" },
  { tint = 18, hex = "#D72B71" },
  { tint = 19, hex = "#A7395D" },
  { tint = 20, hex = "#601226" },
  { tint = 21, hex = "#3E0D18" },
  { tint = 22, hex = "#9F111D" },
  { tint = 23, hex = "#DD132B" },
  { tint = 24, hex = "#CC020B" },
  { tint = 25, hex = "#DE405F" },
  { tint = 26, hex = "#D52BA8" },
  { tint = 27, hex = "#BA14A6" },
  { tint = 28, hex = "#900A9C" },
  { tint = 29, hex = "#5D0764" },
  { tint = 30, hex = "#600653" },
  { tint = 31, hex = "#440549" },
  { tint = 32, hex = "#5D088F" },
  { tint = 33, hex = "#0B2865" },
  { tint = 34, hex = "#0A3A9A" },
  { tint = 35, hex = "#0B63B0" },
  { tint = 36, hex = "#0E95C4" },
  { tint = 37, hex = "#10B6C8" },
  { tint = 38, hex = "#10C196" },
  { tint = 39, hex = "#13B56C" },
  { tint = 40, hex = "#0F862A" },
  { tint = 41, hex = "#0C6B01" },
  { tint = 42, hex = "#5EC52D" },
  { tint = 43, hex = "#B9E020" },
  { tint = 44, hex = "#D8DA1B" },
  { tint = 45, hex = "#F7D313" },
  { tint = 46, hex = "#F2B413" },
  { tint = 47, hex = "#F07E15" },
  { tint = 48, hex = "#F64D00" },
  { tint = 49, hex = "#914713" },
  { tint = 50, hex = "#F0BE71" },
  { tint = 51, hex = "#F4DBB5" },
  { tint = 52, hex = "#DDDCDD" },
  { tint = 53, hex = "#A6A6A6" },
  { tint = 54, hex = "#808180" },
  { tint = 55, hex = "#463E3E" },
  { tint = 56, hex = "#0D0606" },
  { tint = 57, hex = "#488991" },
  { tint = 58, hex = "#3C607F" },
  { tint = 59, hex = "#0C1E4A" },
  { tint = 60, hex = "#93715D" },
  { tint = 61, hex = "#745547" },
  { tint = 62, hex = "#5A4236" },
  { tint = 63, hex = "#2F211C" },
}
Makeup.Palette = "metaped_tint_makeup"
Makeup.PaletteStrip = "tint_makeup"
Makeup.DefaultTint = 0
Makeup.Categories = {
  {
    key = "lipstick",
    group = "makeup",
    tintable = true,
    styles = {
      { label = "none", none = true },
      { label = "matte", id = 0, sheetGrid = 0 },
      { label = "lined", id = 0, sheetGrid = 1 },
      { label = "shadow", id = 0, sheetGrid = 2 },
      { label = "smudged", id = 0, sheetGrid = 3 },
      { label = "square", id = 0, sheetGrid = 4 },
      { label = "heart", id = 0, sheetGrid = 5 },
      { label = "border", id = 0, sheetGrid = 7 },
    },
  },
  {
    key = "blush",
    group = "makeup",
    tintable = true,
    styles = {
      { label = "none", none = true },
      { label = "flushed", id = 0 },
      { label = "rosy", id = 1 },
      { label = "highbrow", id = 2 },
      { label = "contoured", id = 3 },
    },
  },
  {
    key = "eyeshadow",
    group = "makeup",
    tintable = true,
    styles = {
      { label = "none", none = true },
      { label = "smokyEye", id = 0, sheetGrid = 0 },
      { label = "neatArc", id = 0, sheetGrid = 1 },
      { label = "heavyWing", id = 0, sheetGrid = 2 },
      { label = "blendedFlick", id = 0, sheetGrid = 3 },
      { label = "twotoneWing", id = 0, sheetGrid = 4 },
      { label = "highlighted", id = 0, sheetGrid = 5 },
    },
  },
  {
    key = "eyeliner",
    group = "makeup",
    tintable = true,
    styles = {
      { label = "none", none = true },
      { label = "simple", id = 0, sheetGrid = 0 },
      { label = "winged", id = 0, sheetGrid = 1 },
      { label = "long", id = 0, sheetGrid = 2 },
      { label = "underlined", id = 0, sheetGrid = 3 },
      { label = "hooked", id = 0, sheetGrid = 4 },
      { label = "curved", id = 0, sheetGrid = 5 },
      { label = "drama", id = 0, sheetGrid = 6 },
      { label = "indian", id = 0, sheetGrid = 7 },
      { label = "indianBold", id = 0, sheetGrid = 13 },
      { label = "indianFull", id = 0, sheetGrid = 15 },
      { label = "pinup", id = 0, sheetGrid = 8 },
      { label = "pinupBold", id = 0, sheetGrid = 14 },
      { label = "full", id = 0, sheetGrid = 9 },
      { label = "double", id = 0, sheetGrid = 10 },
      { label = "doubleTop", id = 0, sheetGrid = 11 },
      { label = "egyptian", id = 0, sheetGrid = 12 },
    },
  },
  {
    key = "foundation",
    group = "makeup",
    tintable = true,
    styles = {
      { label = "none", none = true },
      { label = "facePowder", id = 0 },
    },
  },
  {
    key = "complex",
    group = "lifestyle",
    tintable = false,
    styles = {
      { label = "none", none = true },
      { label = "exhausted", id = 0 },
      { label = "ruddy", id = 1 },
      { label = "chapped", id = 2 },
      { label = "stippled", id = 3 },
      { label = "flushed", id = 4 },
      { label = "healthyGlow", id = 5 },
      { label = "alcoholic", id = 6 },
      { label = "windWhipped", id = 7 },
      { label = "reddening", id = 8 },
      { label = "toughened", id = 9 },
      { label = "sunBurnt", id = 10 },
      { label = "weathered", id = 11 },
      { label = "fatigued", id = 12 },
      { label = "damaged", id = 13 },
    },
  },
  {
    key = "ageing",
    group = "lifestyle",
    tintable = false,
    styles = {
      { label = "none", none = true },
      { label = "var0", id = 0 },
      { label = "var1", id = 1 },
      { label = "var2", id = 2 },
      { label = "var3", id = 3 },
      { label = "var4", id = 4 },
      { label = "var5", id = 5 },
      { label = "var6", id = 6 },
      { label = "var7", id = 7 },
      { label = "var8", id = 8 },
      { label = "var9", id = 9 },
      { label = "var10", id = 10 },
      { label = "var11", id = 11 },
      { label = "var12", id = 12 },
      { label = "var13", id = 13 },
      { label = "var14", id = 14 },
      { label = "var15", id = 15 },
      { label = "var17", id = 17 },
      { label = "var18", id = 18 },
      { label = "var19", id = 19 },
      { label = "var20", id = 20 },
      { label = "var21", id = 21 },
      { label = "var22", id = 22 },
      { label = "var23", id = 23 },
    },
  },
  {
    key = "freckles",
    group = "lifestyle",
    tintable = false,
    styles = {
      { label = "none", none = true },
      { label = "sunned", id = 0 },
      { label = "cheeky", id = 1 },
      { label = "random", id = 2 },
      { label = "few", id = 3 },
      { label = "several", id = 4 },
      { label = "covered", id = 5 },
      { label = "faded", id = 6 },
      { label = "scattered", id = 7 },
      { label = "lighted", id = 8 },
      { label = "visually", id = 9 },
      { label = "dotted", id = 10 },
      { label = "pinpricked", id = 11 },
      { label = "nosy", id = 12 },
      { label = "cheeked", id = 13 },
      { label = "bigCheeked", id = 14 },
    },
  },
  {
    key = "moles",
    group = "lifestyle",
    tintable = false,
    styles = {
      { label = "none", none = true },
      { label = "odd", id = 0 },
      { label = "flicked", id = 1 },
      { label = "varied", id = 2 },
      { label = "bunch", id = 3 },
      { label = "scarce", id = 4 },
      { label = "speckled", id = 5 },
      { label = "peppered", id = 6 },
      { label = "pronounced", id = 7 },
      { label = "dotted", id = 8 },
      { label = "dwindling", id = 9 },
      { label = "cast", id = 10 },
      { label = "strewn", id = 11 },
      { label = "set", id = 12 },
      { label = "speckledTwo", id = 13 },
      { label = "group", id = 14 },
      { label = "sparse", id = 15 },
    },
  },
  {
    key = "acne",
    group = "lifestyle",
    tintable = false,
    styles = {
      { label = "none", none = true },
      { label = "rugged", id = 0 },
    },
  },
  {
    key = "disc",
    group = "lifestyle",
    tintable = false,
    styles = {
      { label = "none", none = true },
      { label = "rugged", id = 0 },
      { label = "dappled", id = 1 },
      { label = "speckled", id = 2 },
      { label = "styppled", id = 3 },
      { label = "constant", id = 4 },
      { label = "uneven", id = 5 },
      { label = "spotted", id = 6 },
      { label = "minor", id = 7 },
      { label = "hearty", id = 8 },
      { label = "blotched", id = 9 },
      { label = "flecked", id = 10 },
      { label = "random", id = 11 },
      { label = "motley", id = 12 },
      { label = "spread", id = 13 },
      { label = "coarse", id = 14 },
      { label = "patchy", id = 15 },
    },
  },
  {
    key = "spots",
    group = "lifestyle",
    tintable = false,
    styles = {
      { label = "none", none = true },
      { label = "var0", id = 0 },
      { label = "var1", id = 1 },
      { label = "var2", id = 2 },
      { label = "var3", id = 3 },
      { label = "var4", id = 4 },
      { label = "var5", id = 5 },
      { label = "var6", id = 6 },
      { label = "var7", id = 7 },
      { label = "var8", id = 8 },
      { label = "var9", id = 9 },
      { label = "var10", id = 10 },
      { label = "var11", id = 11 },
      { label = "var12", id = 12 },
      { label = "var13", id = 13 },
      { label = "var14", id = 14 },
      { label = "var15", id = 15 },
    },
  },
  {
    key = "scar",
    group = "lifestyle",
    tintable = false,
    styles = {
      { label = "none", none = true },
      { label = "slashed", id = 0 },
      { label = "clawed", id = 1 },
      { label = "split", id = 2 },
      { label = "torn", id = 3 },
      { label = "struck", id = 4 },
      { label = "sliced", id = 5 },
      { label = "hacked", id = 6 },
      { label = "cracked", id = 7 },
      { label = "smashed", id = 8 },
      { label = "patched", id = 9 },
      { label = "scraped", id = 10 },
      { label = "broken", id = 11 },
      { label = "marred", id = 12 },
      { label = "raised", id = 13 },
      { label = "blemished", id = 14 },
      { label = "scalped", id = 15 },
    },
  },
  {
    key = "grime",
    group = "lifestyle",
    tintable = true,
    styles = {
      { label = "none", none = true },
      { label = "var0", id = 0 },
      { label = "var1", id = 1 },
      { label = "var2", id = 2 },
      { label = "var3", id = 3 },
      { label = "var4", id = 4 },
      { label = "var5", id = 5 },
      { label = "var6", id = 6 },
      { label = "var7", id = 7 },
      { label = "var8", id = 8 },
      { label = "var9", id = 9 },
      { label = "var10", id = 10 },
      { label = "var11", id = 11 },
      { label = "var12", id = 12 },
      { label = "var13", id = 13 },
      { label = "var14", id = 14 },
      { label = "var15", id = 15 },
    },
  },
}

Makeup.ByKey = {}
for i = 1, #Makeup.Categories do
  Makeup.ByKey[Makeup.Categories[i].key] = Makeup.Categories[i]
end

local function finiteNumber(value, fallback)
  local number = tonumber(value)
  if not number or number ~= number or number == math.huge or number == -math.huge then return fallback end
  return number
end

function Makeup.GetCategory(key)
  return Makeup.ByKey[key]
end

function Makeup.GetGroup(group)
  local list = {}
  for i = 1, #Makeup.Categories do
    if Makeup.Categories[i].group == group then
      list[#list + 1] = Makeup.Categories[i]
    end
  end
  return list
end

function Makeup.IsValidStyle(key, index)
  local category = Makeup.ByKey[key]
  if not category or type(index) ~= "number" or index ~= math.floor(index) then return false end
  return index >= 1 and index <= #category.styles
end

function Makeup.CleanLook(look)
  local clean = {}
  if type(look) ~= "table" then return clean end
  local maxTint = #Makeup.Colorways - 1
  for key, entry in pairs(look) do
    local style = type(entry) == "table" and tonumber(entry.style) or nil
    if type(key) == "string" and Makeup.IsValidStyle(key, style) then
      local tint = math.floor(finiteNumber(entry.tint, Makeup.DefaultTint))
      local opacity = finiteNumber(entry.opacity, 1.0) + 0.0
      clean[key] = {
        style = math.floor(style),
        tint = math.max(0, math.min(maxTint, tint)),
        opacity = math.max(0.0, math.min(1.0, opacity)),
      }
    end
  end
  return clean
end

function Makeup.GetPrice(key)
  return tonumber(Config.Prices and Config.Prices[key]) or 0.0
end

function Makeup.SectionChanged(key, draft, saved)
  local new = draft and draft[key]
  local old = saved and saved[key]
  local newStyle = new and new.style or 1
  local oldStyle = old and old.style or 1
  if newStyle ~= oldStyle then return true end
  if newStyle <= 1 then return false end
  local category = Makeup.ByKey[key]
  if category and category.tintable and (new.tint or Makeup.DefaultTint) ~= (old.tint or Makeup.DefaultTint) then
    return true
  end
  return math.abs((new.opacity or 1.0) - (old.opacity or 1.0)) > 0.001
end

function Makeup.LooksEqual(a, b)
  for i = 1, #Makeup.Categories do
    if Makeup.SectionChanged(Makeup.Categories[i].key, a, b) then return false end
  end
  return true
end

function Makeup.GetTotal(draft, saved)
  local total = 0.0
  for i = 1, #Makeup.Categories do
    local key = Makeup.Categories[i].key
    if Makeup.SectionChanged(key, draft, saved) then
      local entry = draft and draft[key]
      local removing = (entry and entry.style or 1) <= 1
      if not (removing and Config.FreeToRemove) then
        total = total + Makeup.GetPrice(key)
      end
    end
  end
  return total
end
