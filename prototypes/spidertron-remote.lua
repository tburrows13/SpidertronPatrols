local patrol_remote = table.deepcopy(data.raw["spidertron-remote"]["spidertron-remote"])
patrol_remote.name = "sp-spidertron-remote-patrol"
patrol_remote.icon = "__SpidertronPatrols__/graphics/icon/patrol-remote.png"
patrol_remote.icon_mipmaps = 1
patrol_remote.order = "b[personal-transport]-c[spidertron]-b[remote]-b[patrol-remote]"

local patrol_remote_recipe = {
    type = 'recipe',
    name = 'sp-spidertron-remote-patrol',
    enabled = false,
    ingredients = {
      {'advanced-circuit', 4},
      {"rocket-control-unit", 1},
      {"radar", 1}
    },
    result = 'sp-spidertron-remote-patrol',
  }

data:extend{patrol_remote, patrol_remote_recipe}

