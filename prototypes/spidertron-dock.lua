if not settings.startup["sp-enable-dock"].value then
  return
end

local sounds = require("__base__.prototypes.entity.sounds")
local hit_effects = require ("__base__.prototypes.entity.hit-effects")

local circuit_connections = require "circuit-connections"

local dock_item = {
  type = "item",
  name = "sp-spidertron-dock",
  icon = "__SpidertronPatrols__/graphics/icons/spidertron-dock.png",
  icon_size = 64,
  stack_size = 50,
  place_result = "sp-spidertron-dock",
  order = "b[personal-transport]-c[spidertron]-c[[dock]",  -- '[[' ensures that it is ordered before all spidertron-logistics items
  subgroup = "transport",
}

local dock_recipe = {
  type = "recipe",
  name = "sp-spidertron-dock",
  ingredients = {
    {type="item", name="steel-chest", amount=4},
    {type="item", name="bulk-inserter", amount=4},
  },
  energy_required = 4,
  results = {{type="item", name="sp-spidertron-dock", amount=1}},
  enabled = false
}

local function create_spidertron_dock(inventory_size, closing)
  local name = "sp-spidertron-dock-" .. inventory_size
  local filename = "spidertron-dock-open.png"
  if closing then
    name = "sp-spidertron-dock-closing"
  end
  if inventory_size == 0 and not closing then
    name = "sp-spidertron-dock"
    filename = "spidertron-dock-closed.png"
  end

  local dock = {
    type = "container",
    name = name,
    localised_name = {"entity-name.sp-spidertron-dock"},
    localised_description = {"entity-description.sp-spidertron-dock"},
    icon = "__SpidertronPatrols__/graphics/icons/spidertron-dock.png",
    icon_size = 64,
    inventory_size = inventory_size,
    inventory_type = "with_filters_and_bar",
    hidden = true,
    scale_info_icons = false,
    picture = {
      layers = {
        {
          filename = "__SpidertronPatrols__/graphics/entity/hr-" .. filename,
          height = 199,
          width = 207,
          priority = "high",
          scale = 0.5,
        },
        {
          draw_as_shadow = true,
          filename = "__base__/graphics/entity/artillery-turret/artillery-turret-base-shadow.png",
          height = 149,
          width = 277,
          shift = {0.5625, 0.5},
          priority = "high",
          scale = 0.5,
        },
      }
    },
    circuit_connector_sprites = circuit_connections.circuit_connector_sprites,
    circuit_wire_connection_point = circuit_connections.circuit_wire_connection_point,
    circuit_wire_max_distance = circuit_connections.circuit_wire_max_distance,
    max_health = 600,
    minable = {mining_time = 1, result = "sp-spidertron-dock"},
    placeable_by = {item = "sp-spidertron-dock", count = 1},
    corpse = "artillery-turret-remnants",
    dying_explosion = "assembling-machine-3-explosion",  -- artillery-turret-explosion is too tall
    damaged_trigger_effect = hit_effects.entity(),
    vehicle_impact_sound = sounds.generic_impact,
    close_sound = {
      filename = "__base__/sound/metallic-chest-close.ogg",
      volume = 0.6
    },
    open_sound = {
      filename = "__base__/sound/metallic-chest-open.ogg",
      volume = 0.6
    },
    collision_box = {{-1.1, -1.1}, {1.1, 1.1}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    tile_width = 3,
    tile_height = 3,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    squeak_behaviour = false,  -- Stops squeak through from further reducing the collision box
    se_allow_in_space = true,
  }
  data:extend{dock}
end

create_spidertron_dock(0)
data.raw["container"]["sp-spidertron-dock"].hidden = false
create_spidertron_dock(0, true)  -- "closing" dock, used while the closing animation is being played

-- Standard dock for deepcopying in data-final-fixes
-- Doesn't actually matter if the spidertron ends up with a different inventory_size to 80
create_spidertron_dock(80)

local open_animation = {
  type = "animation",
  name = "sp-spidertron-dock-door",
  filename = "__SpidertronPatrols__/graphics/entity/hr-spidertron-dock-animation.png",
  priority = "medium",
  width = 97,
  height = 79,
  frame_count = 16,
  animation_speed = 0.5,
  --shift = {0.015625, -0.890625},
  scale = 0.5,
}

-- TODO sounds
--[[
  sounds.roboport_door_open,
  sounds.roboport_door_close
]]


data:extend{dock_item, dock_recipe, open_animation}
