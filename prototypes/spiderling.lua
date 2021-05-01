create_spidertron{
  name = "sp-spiderling",
  scale = 0.7,
  leg_scale = 0.75, -- relative to scale
  leg_thickness = 1.2, -- relative to leg_scale
  leg_movement_speed = 0.6
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
    minimap_representation = {scale = 0.3}  -- default = 0.5
  }
}

data.raw["spider-vehicle"]["sp-spiderling"] = spiderling

local spiderling_item = {
  type = "item-with-entity-data",
  name = "sp-spiderling",
  icon = "__SpidertronPatrols__/graphics/icon/spiderling.png",
  icon_tintable = "__SpidertronPatrols__/graphics/icon/spiderling-tintable.png",
  icon_tintable_mask = "__SpidertronPatrols__/graphics/icon/spiderling-tintable-mask.png",
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
    {"exoskeleton-equipment", 2},
    {"solar-panel-equipment", 10},
    {"rocket-launcher", 4},  -- TODO Depends on weapons, add dependency
    {"rocket-control-unit", 4},
    {"low-density-structure", 50},
    {"radar", 1},
    {"effectivity-module-2", 2},
    {"raw-fish", 1}
  },
  result = "sp-spiderling"
}

data:extend{spiderling_item, spiderling_recipe}