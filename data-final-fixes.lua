local spiderling_grid = data.raw["equipment-grid"]["sp-spiderling-equipment-grid"]
if spiderling_grid then
  -- Won't exist if spiderlings are disabled or if another mod removes it
  spiderling_grid.equipment_categories = data.raw["equipment-grid"]["spidertron-equipment-grid"].equipment_categories
end

if mods["AutoTrash"] then
  -- Further workarounds for https://forums.factorio.com/viewtopic.php?f=7&t=98151
  local styles = data.raw["gui-style"].default

  styles.at_right_scroll_pane.maximal_height = 150
  styles.sp_relative_stretchable_frame.maximal_height = 670
end
