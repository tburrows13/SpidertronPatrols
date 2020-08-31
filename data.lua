require 'shortcut'

local patrol_remote = table.deepcopy(data.raw["spidertron-remote"]["spidertron-remote"])
patrol_remote.name = "spidertron-remote-patrol"
patrol_remote.icon = "__SpidertronWaypoints__/thumbnail.png"
patrol_remote.icon_mipmaps = 1

if settings.startup["spidertron-waypoints-use-patrol-remote"] == "always" then
  data.raw["spidertron-remote"]["spidertron-remote"].icon = "__SpidertronWaypoints__/thumbnail.png"
  data.raw["spidertron-remote"]["spidertron-remote"].icon_mipmaps = 1
  patrol_remote.hidden = true  -- Do these even do anything?
  patrol_remote.enabled = false  -- no idea...
end

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
  patrol_remote
})