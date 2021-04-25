-- Misc inputs
local clear_waypoints_key = {
  type = "custom-input",
  name = "clear-spidertron-waypoints",
  key_sequence = "SHIFT + mouse-button-1",
  consuming = "none",
  order = "aa"
}
local disconnect_remote_key = {
  type = "custom-input",
  name = "waypoints-disconnect-remote",
  key_sequence = "",
  linked_game_control = "stack-split",  -- SHIFT + mouse-button-2 by default
  consuming = "none",
  order = "ab"
}
local complete_patrol_key = {
  type = "custom-input",
  name = "waypoints-complete-patrol",
  key_sequence = "ALT + mouse-button-1",
  consuming = "none",
  order = "ac"
}
local change_wait_time_key = {
  type = "custom-input",
  name = "waypoints-change-wait-conditions",
  key_sequence = "Y",
  consuming = "none",
  order = "ad"
}
local change_default_wait_time_key = {
  type = "custom-input",
  name = "waypoints-change-default-wait-conditions",
  key_sequence = "SHIFT + Y",
  consuming = "none",
  order = "ae"
}
local confirm_gui_key = {
  type = "custom-input",
  name = "waypoints-gui-confirm",
  key_sequence = "",
  linked_game_control = "confirm-gui"
}
data:extend{clear_waypoints_key, disconnect_remote_key, complete_patrol_key, change_wait_time_key, change_default_wait_time_key, confirm_gui_key}

-- Allows getting movement control events to detect when to cancel a spidertron's waypoints
data:extend{
  {
    type = "custom-input",
    name = "move-right-custom",
    key_sequence = "",
    linked_game_control = "move-right"
  },
  {
    type = "custom-input",
    name = "move-left-custom",
    key_sequence = "",
    linked_game_control = "move-left"
  },
  {
    type = "custom-input",
    name = "move-up-custom",
    key_sequence = "",
    linked_game_control = "move-up"
  },
  {
    type = "custom-input",
    name = "move-down-custom",
    key_sequence = "",
    linked_game_control = "move-down"
  }
}
