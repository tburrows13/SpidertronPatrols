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
    "military-3",
    "power-armor",
    "exoskeleton-equipment",
    "effectivity-module-2",
    "rocketry",
    "rocket-control-unit",
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

if settings.startup["sp-remove-military-requirement"].value then
  for _, tech in pairs{spiderling_tech, patrol_tech, data.raw.technology["spidertron"]} do
    for i, ingredient in pairs(tech.unit.ingredients) do
      if ingredient[1] == "military-science-pack" then
        table.remove(tech.unit.ingredients, i)
        break
      end
    end
  end
end

if mods["Krastorio2"] then  -- SE undoes these changes
  table.insert(spiderling_tech.prerequisites, "low-density-structure")
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


if (spiderling_enabled or dock_enabled) and not (mods["space-exploration"] or mods["nullius"]) then
  -- Why would the mod be installed if all 3 are disabled...? No idea...

  -- Move rocket control unit unlock earlier in the tech tree, so that spidertron remotes can also be crafed earlier but leave recipe unchanged
  local rcu_tech = data.raw.technology["rocket-control-unit"]
  rcu_tech.prerequisites = {
    --"utility-science-pack",
    "advanced-electronics-2",  -- Added
    "speed-module",
  }
  rcu_tech.unit.ingredients =
  {
    {"automation-science-pack", 1},
    {"logistic-science-pack", 1},
    {"chemical-science-pack", 1},
    --{"utility-science-pack", 1}
  }
  rcu_tech.unit.time = 30  -- Was 45
end


if spiderling_enabled then
  -- Add spiderling, remove exoskeleton, rocketry and rocket-control-unit from spidertron prereqs because they are covered in spiderling
  local spidertron_tech = data.raw.technology.spidertron
  spidertron_tech.prerequisites = {
    "sp-spiderling",  -- Added
    "military-4",
    --"exoskeleton-equipment",
    "fusion-reactor-equipment",
    --"rocketry",
    --"rocket-control-unit",
    "effectivity-module-3"
  }
  table.remove(spidertron_tech.effects, 2)  -- Remove spidertron remote unlock
end