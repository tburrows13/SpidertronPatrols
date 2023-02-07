if not mods["space-exploration"] then return end

-- Additionally code in spidertron-remote that keeps RCUs in spidertron remotes when space-exploration is enabled

if settings.startup["sp-enable-spiderling"].value then
  table.insert(data.raw.recipe["sp-spiderling"].ingredients, {"rocket-control-unit", 4})
  table.insert(data.raw.technology["sp-spiderling"].prerequisites, "rocket-control-unit")
end
