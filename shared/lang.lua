Locales = Locales or {}

function T(key, ...)
  local text = Locales[key]
  if text == nil then return key end
  if select("#", ...) > 0 then
    local ok, formatted = pcall(string.format, text, ...)
    if ok then return formatted end
  end
  return text
end

function TStyle(categoryKey, styleLabel)
  return Locales["style_" .. categoryKey .. "_" .. styleLabel] or Locales["style_" .. styleLabel] or styleLabel
end
