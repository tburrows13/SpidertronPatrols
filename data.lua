require 'shortcut'

local waypoint_remote = table.deepcopy(data.raw["spidertron-remote"]["spidertron-remote"])
waypoint_remote.name = "spidertron-remote-waypoint"
waypoint_remote.icon = nil
waypoint_remote.icons = {{icon = "__base__/graphics/icons/spidertron-remote.png", tint = {r=0.5, g=0.5, b=0.9}}}


local patrol_remote = table.deepcopy(data.raw["spidertron-remote"]["spidertron-remote"])
patrol_remote.name = "spidertron-remote-patrol"
patrol_remote.icon = "__SpidertronWaypoints__/graphics/patrol-remote.png"
patrol_remote.icon_mipmaps = 1

local direct_control = {
  type = "custom-input",
  name = "waypoints-go-to-direct-mode",
  key_sequence = "SHIFT + F",
  order = "da"
}
local waypoint_control = {
  type = "custom-input",
  name = "waypoints-go-to-waypoint-mode",
  key_sequence = "SHIFT + C",
  order = "db"
}
local patrol_control = {
  type = "custom-input",
  name = "waypoints-go-to-patrol-mode",
  key_sequence = "SHIFT + X",
  order = "dc"
}

data:extend({
  {
    type = "custom-input",
    name = "clear-spidertron-waypoints",
    key_sequence = "SHIFT + mouse-button-1",
    consuming = "none",
    order = "aa"
  },
  {
    type = "custom-input",
    name = "waypoints-disconnect-remote",
    key_sequence = "CONTROL + mouse-button-1",
    consuming = "none",
    order = "ab"
  },
  {
    type = "custom-input",
    name = "waypoints-change-wait-conditions",
    key_sequence = "Y",
    consuming = "none",
    order = "ac"
  },
  waypoint_remote,
  patrol_remote,
  direct_control,
  waypoint_control,
  patrol_control,
  {
    type = "custom-input",
    name = "waypoints-gui-confirm",
    key_sequence = "RETURN",
    order = "ad"
  },
})