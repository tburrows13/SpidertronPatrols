local waypoint_shortcut = {
  type = "shortcut",
  name = "spidertron-remote-waypoint",
  action = "lua",
  associated_control_input = "waypoints-waypoint-mode-toggle",
  toggleable = true,
  order = "a",
  icon =
  {
    filename = "__SpidertronWaypoints__/graphics/waypoint-shortcut.png",
    size = 32,
    flags = {"gui-icon"}
  },
  small_icon = {
    filename = "__SpidertronWaypoints__/graphics/waypoint-shortcut-24.png",
    size = 24,
    flags = {"gui-icon"}
  },
  disabled_icon = {
    filename = "__SpidertronWaypoints__/graphics/waypoint-shortcut-white.png",
    size = 32,
    flags = {"gui-icon"}
  },
  disabled_small_icon =
  {
    filename = "__SpidertronWaypoints__/graphics/waypoint-shortcut-white-24.png",
    size = 24,
    flags = {"gui-icon"}
  }
}
local waypoint_toggle = {
	type = "custom-input",
	name = "waypoints-waypoint-mode-toggle",
	key_sequence = "ALT + O",
  consuming = "none",
  order = "ca"
}


local patrol_shortcut = {
  type = "shortcut",
  name = "spidertron-remote-patrol",
  action = "lua",
  associated_control_input = "waypoints-patrol-mode-toggle",
  toggleable = true,
  order = "b",
  icon =
  {
    filename = "__SpidertronWaypoints__/graphics/patrol-shortcut.png",
    size = 32,
    flags = {"gui-icon"}
  },
  small_icon =
  {
    filename = "__SpidertronWaypoints__/graphics/patrol-shortcut-24.png",
    size = 24,
    flags = {"gui-icon"}
  },
  disabled_icon =
  {
    filename = "__SpidertronWaypoints__/graphics/patrol-shortcut-white.png",
    size = 32,
    flags = {"gui-icon"}
  },
  disabled_small_icon =
  {
    filename = "__SpidertronWaypoints__/graphics/patrol-shortcut-white-24.png",
    size = 24,
    flags = {"gui-icon"}
  }
}

local patrol_toggle = {
	type = "custom-input",
	name = "waypoints-patrol-mode-toggle",
	key_sequence = "ALT + P",
  consuming = "none",
  order = "cb"
}


data:extend({waypoint_shortcut, patrol_shortcut, waypoint_toggle, patrol_toggle})
