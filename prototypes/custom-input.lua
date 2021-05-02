-- Misc inputs
local delete_waypoints_key = {
  type = "custom-input",
  name = "sp-delete-all-waypoints",
  key_sequence = "CONTROL + mouse-button-2",
  consuming = "none",
  order = "aa"
}
--[[
local change_default_wait_time_key = {
  type = "custom-input",
  name = "waypoints-change-default-wait-conditions",
  key_sequence = "SHIFT + Y",
  consuming = "none",
  order = "ae"
}
]]

local confirm_gui_key = {
  type = "custom-input",
  name = "sp-confirm-gui",
  key_sequence = "",
  linked_game_control = "confirm-gui"
}
data:extend{delete_waypoints_key, confirm_gui_key}

-- Allows getting movement control events to detect when to turn on 'manual' mode
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
