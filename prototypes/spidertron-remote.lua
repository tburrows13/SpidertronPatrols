local patrol_remote = table.deepcopy(data.raw["spidertron-remote"]["spidertron-remote"])
patrol_remote.name = "sp-spidertron-patrol-remote"
patrol_remote.icon = "__SpidertronPatrols__/graphics/icons/patrol-remote.png"
patrol_remote.icon_mipmaps = 1
patrol_remote.icon_size = 64
patrol_remote.order = "b[personal-transport]-c[spidertron]-b[remote]-b[patrol-remote]"
patrol_remote.flags = {"hidden", "spawnable", "only-in-cursor"}

data:extend{patrol_remote}

