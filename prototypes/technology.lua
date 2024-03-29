local spiderling_tech = {
  type = "technology",
  name = "sp-spiderling",
  icon = "__SpidertronPatrols__/graphics/technology/spiderling.png",  -- 55% scaled tech icon
  icon_size = 256, icon_mipmaps = 4,
  effects = {
    {
      type = "unlock-recipe",
      recipe = "sp-spiderling"
    },
    {
      type = "unlock-recipe",
      recipe = "spidertron-remote"
    }
  },
  prerequisites = {
    "power-armor",
    "exoskeleton-equipment",
    "effectivity-module-2",
    "low-density-structure",
    "military-3",
    "rocketry",
  },
  unit = {
    count = 250,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"military-science-pack", 1},
      {"chemical-science-pack", 1},
  },
    time = 30
  }
}

local patrol_tech = {
  type = "technology",
  name = "sp-spidertron-automation",
  icon = "__SpidertronPatrols__/graphics/technology/spidertron-automation.png",
  icon_size = 256, icon_mipmaps = 1,
  effects = {
    {
      type = "unlock-recipe",
      recipe = "sp-spidertron-dock"
    },
  },
  prerequisites = {
    "sp-spiderling",
    "automated-rail-transportation",
    "stack-inserter",
  },
  unit = {
    count = 500,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"military-science-pack", 1},
      {"chemical-science-pack", 1},
    },
    time = 30
  }
}

if mods["Krastorio2"] then  -- SE undoes this so don't need to worry about K2+SE
  table.insert(spiderling_tech.prerequisites, "kr-radar")
end

-- Modify the above if some features are disabled
local spiderling_enabled = settings.startup["sp-enable-spiderling"].value
local dock_enabled = settings.startup["sp-enable-dock"].value
if not spiderling_enabled then
  patrol_tech.prerequisites = {"chemical-science-pack", "automated-rail-transportation",}
end

if spiderling_enabled then
  data:extend{spiderling_tech}
end
if dock_enabled then
  data:extend{patrol_tech}
end


if spiderling_enabled then
  -- Add spiderling, remove exoskeleton and rocketry from spidertron prereqs because they are covered in spiderling
  local spidertron_tech = data.raw.technology.spidertron
  spidertron_tech.prerequisites = {
    "sp-spiderling",  -- Added
    "military-4",
    --"exoskeleton-equipment",
    "fusion-reactor-equipment",
    --"rocketry",
    "rocket-control-unit",
    "effectivity-module-3"
  }
  for i, effect in pairs(spidertron_tech.effects) do
    if effect.type == "unlock-recipe" and effect.recipe == "spidertron-remote" then
      table.remove(spidertron_tech.effects, i)  -- Remove spidertron remote unlock
      break
    end
  end
end