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
  place_result = "sp-spidertron-dock-0",
  order = "b[personal-transport]-c[spidertron]-c[[dock]",  -- [[ ensures that it is ordered before all spidertron-logistics items
  subgroup = "transport",
}

local dock_recipe = {
  type = "recipe",
  name = "sp-spidertron-dock",
  ingredients = {
    {"steel-chest", 4},
    {"rocket-control-unit", 4}
  },
  energy_required = 4,
  result = "sp-spidertron-dock",
  enabled = false
}


-- "container" definition doesn't support filters, but does support circuit connections
local function create_spidertron_dock(inventory_size, closing)
  local type = "container"
  local logistic_mode
  if settings.startup["sp-dock-is-requester"].value then
    type = "logistic-container"
    logistic_mode = "requester"
  end
  local name = "sp-spidertron-dock-" .. inventory_size
  if closing then name = "sp-spidertron-dock-closing" end
  if data.raw[type][name] then return end
  local filename = "spidertron-dock-open.png"
  if inventory_size == 0 and not closing then
    filename = "spidertron-dock-closed.png"
  end
  local dock = {
    type = type,
    logistic_mode = logistic_mode,
    name = name,
    localised_name = {"entity-name.sp-spidertron-dock"},
    localised_description = {"entity-description.sp-spidertron-dock"},
    icon = "__SpidertronPatrols__/graphics/icons/spidertron-dock.png",
    icon_size = 64,
    inventory_size = inventory_size,
    inventory_type = "with_filters_and_bar",
    enable_inventory_bar = false,
    scale_info_icons = false,
    picture = {
      layers = {
        {
          filename = "__SpidertronPatrols__/graphics/entity/hr-" .. filename,
          height = 199,
          width = 207,
          priority = "high",
          scale = 0.5,
          hr_version = {
            filename = "__SpidertronPatrols__/graphics/entity/hr-" .. filename,
            height = 199,
            width = 207,
            priority = "high",
            scale = 0.5,
          },
        },
        {
          draw_as_shadow = true,
          filename = "__base__/graphics/entity/artillery-turret/artillery-turret-base-shadow.png",
          height = 75,
          width = 138,
          shift = {0.5625, 0.5},
          priority = "high",
          hr_version = {
            draw_as_shadow = true,
            filename = "__base__/graphics/entity/artillery-turret/hr-artillery-turret-base-shadow.png",
            height = 149,
            width = 277,
            shift = {0.5625, 0.5},
            priority = "high",
            scale = 0.5,
          },
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
    collision_box = {{-1.0, -1.0}, {1.0, 1.0}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    tile_width = 3,
    tile_height = 3,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    se_allow_in_space = true,
  }
  data:extend{dock}
end

local sizes_created = {0}
create_spidertron_dock(0)
create_spidertron_dock(0, true)  -- "closing" dock, used while the closing animation is being played
for _, spider_prototype in pairs(data.raw["spider-vehicle"]) do
  local inventory_size = spider_prototype.inventory_size
  if not contains(sizes_created, inventory_size) then
    create_spidertron_dock(inventory_size)
    table.insert(sizes_created, inventory_size)
  end
end

local open_animation = {
  type = "animation",
  name = "sp-spidertron-dock-door",
  filename = "__SpidertronPatrols__/graphics/entity/hr-spidertron-dock-animation.png",
  priority = "medium",
  --width = 52,
  --height = 20,
  width = 97,
  height = 79,
  frame_count = 16,
  animation_speed = 0.5,
  --shift = {0.015625, -0.890625},
  scale = 0.5,
  hr_version =
  {
    filename = "__SpidertronPatrols__/graphics/entity/hr-spidertron-dock-animation.png",
    priority = "medium",
    width = 97,
    height = 79,
    frame_count = 16,
    animation_speed = 0.5,
    --shift = util.by_pixel(-0.25, -29.5),
    scale = 0.5,
  }
}

-- TODO sounds
--[[
  sounds.roboport_door_open,
  sounds.roboport_door_close
]]


data:extend{dock_item, dock_recipe, open_animation}
