if not mods["IndustrialRevolution3"] then return end

local util = require("__SpidertronPatrols__/prototypes/data-util")

local spiderling_enabled = settings.startup["sp-enable-spiderling"].value
local dock_enabled = settings.startup["sp-enable-dock"].value

if spiderling_enabled then
  util.remove_prerequisite("sp-spiderling", "military-3")
  util.add_prerequisite("sp-spiderling", "military-2")

  data.raw.recipe["sp-spiderling"].ingredients = {
    {type="item", name="computer-mk2", amonunt=4},
    {type="item", name="gyroscope", amonunt=1},  -- Ideally would be steel-frame-turret, but this is only unlocked after chrome
    {type="item", name="copper-coil", amonunt=4},
    {type="item", name="low-density-structure", amonunt=60},
    {type="item", name="steel-piston", amonunt=20},
    {type="item", name="rocket-launcher", amonunt=1},
  }
end

if dock_enabled then
  util.remove_prerequisite("sp-spidertron-automation", "bulk-inserter")
  util.add_prerequisite("sp-spidertron-automation", "fast-inserter")

  data.raw.recipe["sp-spidertron-dock"].ingredients = {
    {type="item", name="steel-chest", amonunt=4},
    {type="item", name="fast-inserter", amonunt=8},
  }
end