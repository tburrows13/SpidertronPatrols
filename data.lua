require "prototypes.shortcut"
require "prototypes.custom-input"
require "prototypes.technology"


local waypoint_remote = table.deepcopy(data.raw["spidertron-remote"]["spidertron-remote"])
waypoint_remote.name = "spidertron-remote-waypoint"
waypoint_remote.flags = {"hidden"}
waypoint_remote.icon = "__SpidertronWaypoints__/graphics/icon/waypoint-remote.png"
waypoint_remote.icon_mipmaps = 1

local patrol_remote = table.deepcopy(data.raw["spidertron-remote"]["spidertron-remote"])
patrol_remote.name = "spidertron-remote-patrol"
patrol_remote.flags = {"hidden"}
patrol_remote.icon = "__SpidertronWaypoints__/graphics/icon/patrol-remote.png"
patrol_remote.icon_mipmaps = 1

data:extend{waypoint_remote, patrol_remote}


local styles = data.raw["gui-style"]["default"]
styles.waypoints_switch_padding = {type = "switch_style", parent="switch", top_padding=3}  -- Fixes height of switch to be the same as its labels
styles.waypoints_empty_filler = {type = "empty_widget_style", horizontally_stretchable="on"}