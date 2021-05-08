data:extend({
  {
    type = "bool-setting",
    name = "sp-enable-patrol-remote",
    setting_type = "startup",
    default_value = true,
    order = "a"
  },
  {
    type = "bool-setting",
    name = "sp-enable-dock",
    setting_type = "startup",
    default_value = true,
    order = "b"
  },
  {
    type = "bool-setting",
    name = "sp-enable-spiderling",
    setting_type = "startup",
    default_value = true,
    order = "c"
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
