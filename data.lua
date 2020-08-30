data:extend({
  {
    type = "custom-input",
    name = "clear-spidertron-waypoints",
    key_sequence = "SHIFT + mouse-button-1",
  },
  {
    type = "custom-input",
    name = "remote-cycle-forwards",
    key_sequence = "",
    linked_game_control = "cycle-blueprint-forwards"
  },
  {
    type = "custom-input",
    name = "remote-cycle-backwards",
    key_sequence = "",
    linked_game_control = "cycle-blueprint-backwards"
  },
  {
    type = "spidertron-remote",
    name = "spidertron-remote-patrol",
    icons = {{icon = "__base__/graphics/icons/spidertron-remote.png", tint = {r = 1}}},
    icon_color_indicator_mask = "__base__/graphics/icons/spidertron-remote-mask.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "transport",
    order = "b[personal-transport]-c[spidertron]-b[remote]",
    stack_size = 1,
  }
})