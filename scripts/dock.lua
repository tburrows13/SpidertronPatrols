-- TODO rename file
local math2d = require "__core__.lualib.math2d"

local function on_built(event)
  local entity = event.created_entity or event.entity
  if entity then
    if entity.name == "sp-spidertron-dock-0" then
      global.spidertron_docks[entity.unit_number] = {dock = entity}
      script.register_on_entity_destroyed(entity)
    else
      if entity.type == "spider-vehicle" then
        script.register_on_entity_destroyed(entity)
      end
    end
  end
end
script.on_event(defines.events.on_built_entity, on_built, {{filter = "name", name = "sp-spidertron-dock-0"}, {filter = "type", type = "spider-vehicle"}})
script.on_event(defines.events.on_robot_built_entity, on_built, {{filter = "name", name = "sp-spidertron-dock-0"}, {filter = "type", type = "spider-vehicle"}})
script.on_event(defines.events.script_raised_revive, on_built, {{filter = "name", name = "sp-spidertron-dock-0"}, {filter = "type", type = "spider-vehicle"}})
script.on_event(defines.events.script_raised_built, on_built, {{filter = "name", name = "sp-spidertron-dock-0"}, {filter = "type", type = "spider-vehicle"}})

function on_entity_destroyed(event)
  local unit_number = event.unit_number
  if unit_number then
    -- Entity is a dock
    local dock_data = global.spidertron_docks[unit_number]
    if dock_data then
      local spidertron = dock_data.connected_spidertron
      if spidertron and spidertron.valid then
        global.spidertrons_docked[spidertron.unit_number] = nil
      end
      global.spidertron_docks[unit_number] = nil
    end

    -- Entity is a spidertron
    local dock_unit_number = global.spidertrons_docked[unit_number]
    if dock_unit_number then
      global.spidertrons_docked[unit_number] = nil

      dock_data = global.spidertron_docks[dock_unit_number]
      if dock_data then
        local dock = dock_data.dock
        if dock.valid then
          dock.surface.create_entity{name = "flying-text", position = dock.position, text = {"flying-text.spidertron-removed"}}

          dock = replace_dock(dock, "sp-spidertron-dock-0")
          global.spidertron_docks[dock.unit_number] = {dock = dock}
        end
      end
    end
  end
end


script.on_event(defines.events.on_pre_player_mined_item,
  function(event)
    -- Dock inventories should never return their contents to the player
    -- because all their items are duplicates from the spidertron's inventory
    local dock = event.entity
    if dock and string.sub(dock.name, 0, 14) == "sp-spidertron-" then
      local dock_inventory = dock.get_inventory(defines.inventory.chest)
      dock_inventory.clear()
    end
  end
)


function replace_dock(dock, new_dock_name)
  local health = dock.health
  local last_user = dock.last_user
  --local circuit_connected_entities = dock.circuit_connected_entities
  local circuit_connection_definitions = dock.circuit_connection_definitions
  local to_be_deconstructed = dock.to_be_deconstructed()

  local players_with_gui_open = {}
  for _, player in pairs(game.connected_players) do
    if player.opened == dock then
      table.insert(players_with_gui_open, player)
    end
  end

  old_dock = dock
  dock = dock.surface.create_entity{name = new_dock_name, position = dock.position, force = dock.force, spill = false, create_build_effect_smoke = false}

  dock.health = health
  dock.last_user = last_user

  for _, definition in pairs(circuit_connection_definitions) do
    dock.connect_neighbour{
      wire = definition.wire,
      target_entity = definition.target_entity,
      target_circuit_id = definition.target_circuit_id
    }
  end

  if to_be_deconstructed then
    dock.order_deconstruction(dock.force)
  end

  for _, player in pairs(players_with_gui_open) do
    if player.valid then
      player.opened = dock
    end
  end

  script.register_on_entity_destroyed(dock)
  old_dock.destroy()

  return dock
end


local function update_dock_inventory(dock, spidertron, previous_contents)
  local spidertron_inventory = spidertron.get_inventory(defines.inventory.spider_trunk)
  local spidertron_contents = spidertron_inventory.get_contents()

  -- Can't deal with filters because "container" entities don't support them

  local dock_inventory = dock.get_inventory(defines.inventory.chest)
  local dock_contents = dock_inventory.get_contents()

  local spidertron_diff = table_diff(spidertron_contents, previous_contents)
  for item_name, count in pairs(spidertron_diff) do
    if count > 0 then
      dock_inventory.insert{name = item_name, count = count}
    else
      dock_inventory.remove{name = item_name, count = -count}
    end
  end

  local dock_diff = table_diff(dock_contents, previous_contents)
  for item_name, count in pairs(dock_diff) do
    if count > 0 then
      spidertron_inventory.insert{name = item_name, count = count}
    else
      spidertron_inventory.remove{name = item_name, count = -count}
    end
  end

  spidertron_inventory.sort_and_merge()
  dock_inventory.sort_and_merge()

  local new_spidertron_contents = spidertron_inventory.get_contents()
  local new_dock_contents = dock_inventory.get_contents()
  assert(table_equals(new_spidertron_contents, new_dock_contents))  -- TODO Remove for release
  return new_spidertron_contents
end


local function update_dock(dock_data)
  local dock = dock_data.dock
  local delete = false
  if dock.valid then
    local surface = dock.surface
    local spidertron = dock_data.connected_spidertron
    if spidertron and spidertron.valid then
      -- Port is connected. Check update inventories, then undock if needed
      dock_data.previous_contents = update_dock_inventory(dock, spidertron, dock_data.previous_contents)

      -- 0.1 * 216 ~ 20km/h
      if dock.to_be_deconstructed() or spidertron.speed > 0.1 or not math2d.bounding_box.collides_with(dock.bounding_box, spidertron.bounding_box) then
        -- Spidertron needs to become undocked
        global.spidertrons_docked[spidertron.unit_number] = nil
        surface.create_entity{name = "flying-text", position = dock.position, text = {"flying-text.spidertron-undocked"}}

        dock = replace_dock(dock, "sp-spidertron-dock-0")
        global.spidertron_docks[dock.unit_number] = {dock = dock}
        delete = true
      end
    else
      if spidertron then
        -- `spidertron` is not valid
        dock_data = {dock = dock_data.dock}
      end

      -- Check if dock should initiate connection
      if not dock.to_be_deconstructed() then
        local nearby_spidertrons = surface.find_entities_filtered{type = "spider-vehicle", area = dock.bounding_box, force = dock.force}
        local spidertrons_docked = global.spidertrons_docked
        for _, spidertron in pairs(nearby_spidertrons) do
          if not global.spidertrons_docked[spidertron.unit_number] and spidertron.speed < 0.1 and spidertron.name ~= "companion" then
            local inventory = spidertron.get_inventory(defines.inventory.spider_trunk)
            local inventory_size = #inventory
            if inventory_size > 0 then
              -- Switch dock entity out for one with the correct inventory size
              dock = replace_dock(dock, "sp-spidertron-dock-" .. inventory_size)
              dock_data.dock = dock
              global.spidertron_docks[dock.unit_number] = dock_data
              delete = true

              dock_data.connected_spidertron = spidertron
              spidertrons_docked[spidertron.unit_number] = dock.unit_number
              --game.print("Spidertron docked")
              surface.create_entity{name = "flying-text", position = dock.position, text = {"flying-text.spidertron-docked"}}

              local spidertron_contents = inventory.get_contents()
              local dock_inventory = dock.get_inventory(defines.inventory.chest)
              for item_name, count in pairs(spidertron_contents) do
                dock_inventory.insert{name = item_name, count = count}
              end
              dock_data.previous_contents = spidertron_contents
              break
            end
          end
        end
      end
    end
  else
    delete = true
  end
  return nil, delete  -- Deletes dock from global table
end
script.on_event(defines.events.on_tick,
  function()
    if next(global.spidertron_docks) then
      -- TODO Replace '20' with configurable setting?
      global.from_k = for_n_of(global.spidertron_docks, global.from_k, 20, update_dock)
    end
  end
)

return {on_entity_destroyed = on_entity_destroyed}