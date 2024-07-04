if not mods["IndustrialRevolution3"] then return end

local util = require("__SpidertronPatrols__/prototypes/data-util")

local spiderling_enabled = settings.startup["sp-enable-spiderling"].value
local dock_enabled = settings.startup["sp-enable-dock"].value

if spiderling_enabled then
  util.remove_prerequisite("sp-spiderling", "military-3")
  util.add_prerequisite("sp-spiderling", "military-2")

  data.raw.recipe["sp-spiderling"].ingredients = {
    {"computer-mk2", 4},
    {"gyroscope", 1},  -- Ideally would be steel-frame-turret, but this is only unlocked after chrome
    {"copper-coil", 4},
    {"low-density-structure", 60},
    {"steel-piston", 20},
    {"rocket-launcher", 1},
  }
end

if dock_enabled then
  util.remove_prerequisite("sp-spidertron-automation", "stack-inserter")
  util.add_prerequisite("sp-spidertron-automation", "fast-inserter")

  data.raw.recipe["sp-spidertron-dock"].ingredients = {
    {"steel-chest", 4},
    {"fast-inserter", 8},
  }
end