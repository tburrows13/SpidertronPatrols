require "prototypes.custom-input"
require "prototypes.spidertron-remote"
require "prototypes.technology"

local empty_entity = {
  name = "sp-spidertron-waypoint",
  type = "simple-entity-with-owner",
  icon = "__SpidertronWaypoints__/graphics/icon/spidertron-dock.png", icon_size = 64,
  picture = util.empty_sprite(),
  selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
  selection_priority = 255, -- Default 50, Max 255
  collision_mask = nil,
  minable = nil,
  force_visibility = "same",
  flags = {"placeable-off-grid"}
}
data:extend{empty_entity}

local styles = data.raw["gui-style"]["default"]
styles.waypoints_switch_padding = {type = "switch_style", parent="switch", top_padding=3}  -- Fixes height of switch to be the same as its labels
styles.waypoints_empty_filler = {type = "empty_widget_style", horizontally_stretchable="on"}