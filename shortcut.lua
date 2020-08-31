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

local patrol_toggle = {
	type = "custom-input",
	name = "waypoints-patrol-mode",
	key_sequence = "ALT + P",
	consuming = "none"
}

local waypoint_toggle = {
	type = "custom-input",
	name = "waypoints-waypoint-mode",
	key_sequence = "ALT + O",
	consuming = "none"
}

local patrol_toggle_click = {
  type = "custom-input",
  name = "waypoints-patrol-mode-click",
  key_sequence = "SHIFT + mouse-button-2",
}
local patrol_toggle_scroll = {
  type = "custom-input",
  name = "waypoints-patrol-mode-scroll",
  key_sequence = "",
  linked_game_control = "cycle-blueprint-forwards"
}

local waypoint_toggle_click = {
  type = "custom-input",
  name = "waypoints-waypoint-mode-click",
  key_sequence = "mouse-button-2",
}
local waypoint_toggle_scroll = {
  type = "custom-input",
  name = "waypoints-waypoint-mode-scroll",
  key_sequence = "",
  linked_game_control = "cycle-blueprint-backwards"
}

--[[local pick_item = {
  type = "custom-input",
  name = "pick-item-custom",
  key_sequence = "",
  linked_game_control = "pick-item"
}]]


--local p


data:extend({patrol_shortcut, waypoint_shortcut, patrol_toggle, waypoint_toggle, patrol_toggle_click, patrol_toggle_scroll, waypoint_toggle_click, waypoint_toggle_scroll})
--data:extend({pick_item})