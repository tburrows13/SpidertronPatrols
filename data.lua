require "prototypes.custom-input"
require "prototypes.spidertron-remote"
require "prototypes.technology"

local styles = data.raw["gui-style"]["default"]
styles.waypoints_switch_padding = {type = "switch_style", parent="switch", top_padding=3}  -- Fixes height of switch to be the same as its labels
styles.waypoints_empty_filler = {type = "empty_widget_style", horizontally_stretchable="on"}