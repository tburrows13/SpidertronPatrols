data:extend{
  {
    type = "technology",
    name = "sp-spidertron-automation",
    icon = "__base__/graphics/technology/spidertron.png",
    icon_size = 256, icon_mipmaps = 4,
    effects = {
      {
        recipe = "sp-spidertron-dock",
        type = "unlock-recipe"
      },
    },
    prerequisites = {
      "spidertron",
    },
    unit = {
      count = 5000,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1}
    },
      time = 30
    }
  }
}