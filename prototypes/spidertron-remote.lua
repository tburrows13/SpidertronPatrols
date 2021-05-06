if not settings.startup["sp-enable-patrol-remote"].value then
  return
end


local patrol_remote = table.deepcopy(data.raw["spidertron-remote"]["spidertron-remote"])
patrol_remote.name = "sp-spidertron-patrol-remote"
patrol_remote.icon = "__SpidertronPatrols__/graphics/icons/patrol-remote.png"
patrol_remote.icon_mipmaps = 1
patrol_remote.icon_size = 64
patrol_remote.order = "b[personal-transport]-c[spidertron]-b[remote]-b[patrol-remote]"

local patrol_remote_recipe = {
  type = "recipe",
  name = "sp-spidertron-patrol-remote",
  enabled = false,
  ingredients = {
    {"advanced-circuit", 4},
    {"rocket-control-unit", 1},
    {"radar", 1}
  },
  result = "sp-spidertron-patrol-remote",
}

data:extend{patrol_remote, patrol_remote_recipe}

