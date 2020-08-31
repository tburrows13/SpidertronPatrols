local patrol_shortcut = {
  type = "shortcut",
  name = "waypoints-patrol-mode",
  action = "lua",
  associated_control_input = "waypoints-patrol-mode",
  toggleable = true,
  order = "b",
  icon =
  {
    filename = "__SpidertronWaypoints__/graphics/patrol-icon.png",
    size = 32,
    flags = {"icon"}
    }
}

local waypoint_shortcut = {
  type = "shortcut",
  name = "waypoints-waypoint-mode",
  action = "lua",
  associated_control_input = "waypoints-waypoint-mode",
  toggleable = true,
  order = "a",
  icon =
  {
    filename = "__SpidertronWaypoints__/graphics/waypoint-icon.png",
    size = 32,
    flags = {"icon"}
    }
}

local patrol_input = {
	type = "custom-input",
	name = "waypoints-patrol-mode",
	key_sequence = "ALT + P",
	consuming = "none"
}

local waypoint_input = {
	type = "custom-input",
	name = "waypoints-waypoint-mode",
	key_sequence = "ALT + O",
	consuming = "none"
}


data:extend({patrol_shortcut, waypoint_shortcut, patrol_input, waypoint_input})