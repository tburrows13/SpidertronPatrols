data:extend({
  {
    type = "bool-setting",
    name = "sp-enable-dock",
    setting_type = "startup",
    default_value = true,
    order = "ab"
  },
  {
    type = "bool-setting",
    name = "sp-enable-spiderling",
    setting_type = "startup",
    default_value = true,
    order = "ac"
  },
  {
    type = "bool-setting",
    name = "sp-dock-is-requester",
    setting_type = "startup",
    default_value = false,
    order = "b"
  },
  {
    type = "bool-setting",
    name = "sp-remove-military-requirement",
    setting_type = "startup",
    default_value = false,
    order = "c"
  },
  {
    type = "bool-setting",
    name = "sp-show-waypoint-numbers-in-alt-mode",
    setting_type = "runtime-per-user",
    default_value = true,
    order = "a"
  },

  {
    type = "double-setting",
    name = "sp-window-height-scale",
    setting_type = "runtime-per-user",
    default_value = 1,
    minimum_value = 0.2,
    maximum_value = 5,
    order = "b"
  },
})

-- Remove workaround for https://forums.factorio.com/98151
local util = require "util"
base_version = tonumber(util.split(mods["base"], ".")[3])
if base_version >= 77 then
  data.raw["double-setting"]["sp-window-height-scale"].default_value = 5
  data.raw["double-setting"]["sp-window-height-scale"].allowed_values = {5}
  data.raw["double-setting"]["sp-window-height-scale"].hidden = true
end
