-- Done in data-final-fixes.lua because several mods make changes to equipment categories
-- Let me know if you need this moved to a different data stage

if not settings.startup["sp-enable-spiderling"].value then
  return
end


data:extend{
  util.merge{
    data.raw["equipment-grid"]["spidertron-equipment-grid"],
    {
      name = "sp-spiderling-equipment-grid",
      width = 10,
      height = 4,
    }
  }
}
