if not settings.startup["sp-enable-dock"].value then
  return
end

local dock_template = table.deepcopy(data.raw["container"]["sp-spidertron-dock-80"])

if not (data.raw["spider-vehicle"]["spidertron"] and data.raw["spider-vehicle"]["spidertron"].inventory_size == 80) then
  -- Might as well delete the template if it won't actually be used. If another spidertron has inventory_size = 80 it will just get recreated later.
  data.raw["container"]["sp-spidertron-dock-80"] = nil
end

local function create_spidertron_dock(inventory_size)
  local name = "sp-spidertron-dock-" .. inventory_size

  if data.raw["container"][name] and data.raw["container"][name].inventory_size == inventory_size then return end

  local dock = table.deepcopy(dock_template)
  dock.name = name
  dock.inventory_size = inventory_size

  data:extend{dock}
end

for _, spider_prototype in pairs(data.raw["spider-vehicle"]) do
  local inventory_size = spider_prototype.inventory_size
  create_spidertron_dock(inventory_size)
end
