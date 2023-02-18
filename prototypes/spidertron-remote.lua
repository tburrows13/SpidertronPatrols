local patrol_remote = table.deepcopy(data.raw["spidertron-remote"]["spidertron-remote"])
patrol_remote.name = "sp-spidertron-patrol-remote"
patrol_remote.icon = "__SpidertronPatrols__/graphics/icons/patrol-remote.png"
patrol_remote.icon_mipmaps = 1
patrol_remote.icon_size = 64
patrol_remote.order = "b[personal-transport]-c[spidertron]-b[remote]-b[patrol-remote]"
patrol_remote.flags = {"hidden", "spawnable", "only-in-cursor"}

local font_start = "[font=default-semibold][color=255, 230, 192]"
local font_end = "[/color][/font]"
local line_start = "\n  •   "
patrol_remote.localised_description = {
  "",
  font_start,
  {"gui.instruction-when-in-cursor"},
  ":",
  line_start,
  {"item-description.sp-create-waypoint"},
  line_start,
  {"item-description.sp-replace-waypoint"},
  line_start,
  {"item-description.sp-delete-waypoints"},
  line_start,
  {"item-description.spe-open-inventory"},
  font_end,
}

data:extend{patrol_remote}

if not mods["space-exploration"] then  -- RCU is unlocked earlier in SE so we don't need to change it
  data.raw.recipe["spidertron-remote"].ingredients = {
    {"processing-unit", 1},  -- Remove RCU requirement since it needs to be crafted at chemical science
    {"radar", 1}
  }
end