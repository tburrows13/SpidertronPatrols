if not mods["nullius"] then return end

local dock_enabled = settings.startup["sp-enable-dock"].value
if dock_enabled and sp_data_stage ~= "data" then
  local item = data.raw.item["sp-spidertron-dock"]
  item.group = "equipment"
  item.subgroup = "vehicle"
  item.order = "nullius-dh"

  local recipe = data.raw.recipe["sp-spidertron-dock"]
  recipe.group = "equipment"
  recipe.subgroup = "vehicle"
  recipe.order = "nullius-dh"
  recipe.category = "medium-crafting"
  recipe.energy_required = 60
  recipe.ingredients = {
    {"nullius-large-chest-2", 2},
    {"nullius-sensor-2", 1}
  }

  local type = "container"
  if settings.startup["sp-dock-is-requester"].value then
    type = "logistic-container"
  end

  for name, entity in pairs(data.raw[type]) do
    if string.sub(name, 1, 18) == "sp-spidertron-dock" then
      entity.order = "nullius-dh"
    end
  end

  if sp_data_stage == "data-updates" then
    local tech = data.raw.technology["nullius-personal-transportation-4"]
    table.insert(tech.effects, {
      type = "unlock-recipe",
      recipe = "sp-spidertron-dock"
    })
  end
end

local patrol_enabled = settings.startup["sp-enable-patrol-remote"].value
if patrol_enabled then
  local item = data.raw["spidertron-remote"]["sp-spidertron-patrol-remote"]
  item.group = "equipment"
  item.subgroup = "vehicle"
  item.order = "nullius-dg"

  local recipe = data.raw.recipe["sp-spidertron-patrol-remote"]
  recipe.group = "equipment"
  recipe.subgroup = "vehicle"
  recipe.order = "nullius-dg"
  recipe.category = "tiny-crafting"
  recipe.energy_required = 20
  recipe.ingredients = {
    {"nullius-processor-2", 2},
    {"nullius-scout-remote", 2}
  }

  if sp_data_stage == "data-updates" then
    local tech = data.raw.technology["nullius-personal-transportation-4"]
    table.insert(tech.effects, 3, {
      type = "unlock-recipe",
      recipe = "sp-spidertron-patrol-remote"
    })
  end
end

