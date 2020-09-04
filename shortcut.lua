local waypoint_shortcut = {
  type = "shortcut",
  name = "spidertron-remote-waypoint",
  action = "lua",
  associated_control_input = "waypoints-waypoint-mode-toggle",
  toggleable = true,
  order = "a",
  icon =
  {
    filename = "__SpidertronWaypoints__/graphics/waypoint-icon.png",
    size = 32,
    flags = {"icon"}
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
    filename = "__SpidertronWaypoints__/graphics/patrol-icon.png",
    size = 32,
    flags = {"icon"}
    }
}
local patrol_toggle = {
	type = "custom-input",
	name = "waypoints-patrol-mode-toggle",
	key_sequence = "ALT + P",
  consuming = "none",
  order = "cb"
}

local scroll_forwards = {
  type = "custom-input",
  name = "waypoints-mode-scroll-forwards",
  key_sequence = "",
  linked_game_control = "cycle-blueprint-forwards"
}
local scroll_backwards = {
  type = "custom-input",
  name = "waypoints-mode-scroll-backwards",
  key_sequence = "",
  linked_game_control = "cycle-blueprint-backwards"
}
local scroll_forwards_key = {
  type = "custom-input",
  name = "waypoints-mode-scroll-forwards-key",
  key_sequence = "",
  order="ba"
}
local scroll_backwards_key = {
  type = "custom-input",
  name = "waypoints-mode-scroll-backwards-key",
  key_sequence = "",
  order="bb"
}

--[[local waypoint_toggle_click = {
  type = "custom-input",
  name = "waypoints-waypoint-mode-click",
  key_sequence = "mouse-button-2",
}]]
--[[local patrol_toggle_click = {
  type = "custom-input",
  name = "waypoints-patrol-mode-click",
  key_sequence = "SHIFT + mouse-button-2",
}]]




--[[local pick_item = {
  type = "custom-input",
  name = "pick-item-custom",
  key_sequence = "",
  linked_game_control = "pick-item"
}]]


--local p


data:extend({waypoint_shortcut, patrol_shortcut, waypoint_toggle, patrol_toggle, scroll_forwards, scroll_backwards, scroll_forwards_key, scroll_backwards_key})
--data:extend({pick_item})