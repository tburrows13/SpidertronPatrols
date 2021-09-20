data:extend({
  {
    type = "bool-setting",
    name = "sp-enable-patrol-remote",
    setting_type = "startup",
    default_value = true,
    order = "aa"
  },
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
    type = "double-setting",
    name = "sp-window-height-scale",
    setting_type = "runtime-per-user",
    default_value = 1,
    minimum_value = 0.2,
    maximum_value = 5,
    order = "a"
  },
})
