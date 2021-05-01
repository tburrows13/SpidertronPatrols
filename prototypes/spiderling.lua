create_spidertron{
  name = "sp-spiderling",
  scale = 0.7,
  leg_scale = 0.75, -- relative to scale
  leg_thickness = 1.15, -- relative to leg_scale
  leg_movement_speed = 0.4
}

local spiderling = data.raw["spider-vehicle"]["sp-spiderling"]
spiderling = util.merge{
  spiderling,
  {
    inventory_size = 20,  -- default = 80
    torso_rotation_speed = 0.007,  -- default = 0.005
    height = spiderling.height * 1.3,
    chunk_exploration_radius = 1,  -- default = 3
    minable = {result = "sp-spiderling"},
  }
}

data.raw["spider-vehicle"]["sp-spiderling"] = spiderling

local spiderling_item = {
  type = "item-with-entity-data",
  name = "sp-spiderling",
  icon = "__base__/graphics/icons/spidertron.png",
  icon_tintable = "__base__/graphics/icons/spidertron-tintable.png",
  icon_tintable_mask = "__base__/graphics/icons/spidertron-tintable-mask.png",
  icon_size = 64, icon_mipmaps = 4,
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
    {"exoskeleton-equipment", 2},
    {"solar-panel-equipment", 20},
    {"rocket-launcher", 4},  -- TODO Depends on weapons, add dependency
    {"low-density-structure", 50},
    {"radar", 1},
    {"effectivity-module-2", 2},
    {"raw-fish", 1}
  },
  result = "sp-spiderling"
}

data:extend{spiderling_item, spiderling_recipe}