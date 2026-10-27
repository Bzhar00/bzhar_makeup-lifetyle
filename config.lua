Config = {}

Config.Currency = 0 -- 0 is cash, 1 is gold

Config.Prices = { -- Price of each section
  lipstick   = 3.0,
  blush      = 3.0,
  eyeshadow  = 4.0,
  eyeliner   = 4.0,
  foundation = 5.0,
  complex    = 6.0,
  ageing     = 6.0,
  freckles   = 4.0,
  moles      = 4.0,
  acne       = 4.0,
  disc       = 5.0,
  spots      = 4.0,
  scar       = 8.0,
  grime      = 2.0,
}

Config.FreeToRemove = true -- Setting a section back to None is free

Config.ShowMakeup = true -- Show the Makeup menu

Config.ShowLifestyle = true -- Show the Lifestyle menu

Config.OpenKey = "INPUT_DYNAMIC_SCENARIO" -- Key that opens the menu

Config.SitInChair = true -- Sit the player in the barber chair first

Config.Camera = {
  distance = 1.50, -- Distance from the face
  height   = 0.00, -- Moves the camera up or down
  fov      = 24.0, -- Zoom, lower is closer
}

Config.Blip = {
  enable = true, -- Show a blip on every shop
  sprite = "blip_shop_barber", -- Blip icon
  scale  = 0.2, -- Blip size
}

Config.Locations = { -- Shops, radius is how close the player must stand
  { name = "Valentine",   coords = vector3(-307.51, 813.96, 118.99),    radius = 1.5 },
  { name = "Blackwater",  coords = vector3(-814.91, -1367.89, 43.75),   radius = 2.0 },
  { name = "Saint Denis", coords = vector3(2655.21, -1179.90, 53.27),   radius = 2.0 },
  { name = "Annesburg",   coords = vector3(2924.30, 1343.70, 44.40),    radius = 1.5 },
  { name = "Armadillo",   coords = vector3(-3684.22, -2621.05, -13.44), radius = 1.5 },
  { name = "Tumbleweed",  coords = vector3(-5493.40, -2940.70, -0.46),  radius = 1.5 },
  { name = "Strawberry",  coords = vector3(-1810.92, -372.15, 162.89),  radius = 1.5 },
}

Config.RefreshCommand = "makeuprefresh" -- Puts your saved makeup back on, false turns it off

Config.Debug = false -- Print each step in the F8 and server console
