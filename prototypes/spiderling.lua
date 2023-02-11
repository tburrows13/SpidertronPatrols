if not settings.startup["sp-enable-spiderling"].value then
  return
end

create_spidertron{
  name = "sp-spiderling",
  scale = 0.7,
  leg_scale = 0.75, -- relative to scale
  leg_thickness = 1.2, -- relative to leg_scale
  leg_movement_speed = 0.62
}

local spiderling = data.raw["spider-vehicle"]["sp-spiderling"]
spiderling = util.merge{
  spiderling,
  {
    icon = "__SpidertronPatrols__/graphics/icons/spiderling.png",
    icon_size = 64, icon_mipmaps = 1,
    inventory_size = 30,  -- default = 80
    torso_rotation_speed = 0.007,  -- default = 0.005
    torso_bob_speed = 1.2,  -- default = 1
    height = spiderling.height * 1.3,
    chunk_exploration_radius = 2,  -- default = 3
    minable = {result = "sp-spiderling"},
    max_health = 1000,  -- default = 3000
    minimap_representation = {scale = 0.3},  -- default = 0.5
    automatic_weapon_cycling = false,
    chain_shooting_cooldown_modifier = 1,  -- default 0.5, has no effect because automatic_weapon_cycling = false
    equipment_grid = "sp-spiderling-equipment-grid",
  }
}
spiderling.guns = {"sp-spiderling-rocket-launcher"}
data.raw["spider-vehicle"]["sp-spiderling"] = spiderling

data:extend{
  util.merge{
    data.raw["gun"]["spidertron-rocket-launcher-2"],
    {
      name = "sp-spiderling-rocket-launcher",
      attack_parameters = {
        range = 24,  -- default = 36
        cooldown = 120,  -- default = 60 (ticks)
      }
    }
  }
}
data.raw["gun"]["sp-spiderling-rocket-launcher"].localised_name = nil

local spiderling_item = {
  type = "item-with-entity-data",
  name = "sp-spiderling",
  icon = "__SpidertronPatrols__/graphics/icons/spiderling.png",
  icon_tintable = "__SpidertronPatrols__/graphics/icons/spiderling-tintable.png",
  icon_tintable_mask = "__SpidertronPatrols__/graphics/icons/spiderling-tintable-mask.png",
  icon_size = 64, icon_mipmaps = 1,
  subgroup = "transport",
  order = "b[personal-transport]-c[spidertron]-a[[spiderling]",
  place_result = "sp-spiderling",
  stack_size = 1
}

local spiderling_recipe = {
  type = "recipe",
  name = "sp-spiderling",
  enabled = false,
  energy_required = 5,
  ingredients =
  {
    {"exoskeleton-equipment", 4},
    {"rocket-launcher", 1},
    {"low-density-structure", 40},
    {"radar", 1},
    {"effectivity-module-2", 2},
    {"raw-fish", 1}
  },
  result = "sp-spiderling"
}

data:extend{spiderling_item, spiderling_recipe}
