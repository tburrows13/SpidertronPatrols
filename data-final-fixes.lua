local spiderling_grid = data.raw["equipment-grid"]["sp-spiderling-equipment-grid"]
if spiderling_grid then
  -- Won't exist if spiderlings are disabled or if another mod removes it
  spiderling_grid.equipment_categories = data.raw["equipment-grid"]["spidertron-equipment-grid"].equipment_categories
end
