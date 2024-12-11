local math2d = require "math2d"

---@alias ItemName string
---@alias QualityName string
---@alias InventoryContents table<ItemName, table<QualityName, number>>

---@class DockData
---@field dock LuaEntity
---@field connected_spidertron LuaEntity?
---@field previous_contents {items: InventoryContents, filters: ItemFilter[]}?

local Dock = {}

---@param event EventData.on_built_entity|EventData.on_entity_cloned
local function on_built(event)
  local entity = event.entity or event.destination
  if entity then
    if not (entity.type == "container" or entity.type == "spider-vehicle") then return end
    if entity.type == "spider-vehicle" then
      script.register_on_object_destroyed(entity)
    elseif entity.name == "sp-spidertron-dock" then
      storage.spidertron_docks[entity.unit_number] = {dock = entity}
      script.register_on_object_destroyed(entity)
    elseif entity.name:sub(0, 19) == "sp-spidertron-dock-" then
      -- a non-zero-capacity dock has been created, from on_entity_cloned or built from blueprint
      entity = replace_dock(entity, "sp-spidertron-dock")
      storage.spidertron_docks[entity.unit_number] = {dock = entity}
    end
  end
end
-- TODO add filter back
-- local on_built_filter = {{filter = "type", type = "container"}, {filter = "type", type = "spider-vehicle"}}

---@param event EventData.on_object_destroyed
function on_object_destroyed(event)
  local unit_number = event.useful_id
  if unit_number then
    -- Entity is a dock
    local dock_data = storage.spidertron_docks[unit_number]
    if dock_data then
      local spidertron = dock_data.connected_spidertron
      if spidertron and spidertron.valid then
        storage.spidertrons_docked[spidertron.unit_number] = nil
      end
      storage.spidertron_docks[unit_number] = nil
    end

    -- Entity is a spidertron
    local dock_unit_number = storage.spidertrons_docked[unit_number]
    if dock_unit_number then
      storage.spidertrons_docked[unit_number] = nil

      dock_data = storage.spidertron_docks[dock_unit_number]
      if dock_data then
        local dock = dock_data.dock
        if dock.valid then
          --dock.surface.create_entity{name = "flying-text", position = dock.position, text = {"flying-text.spidertron-removed"}}

          dock = replace_dock(dock, "sp-spidertron-dock")
          storage.spidertron_docks[dock.unit_number] = {dock = dock}
        end
      end
    end
  end
end

---@param event EventData.on_pre_player_mined_item
local function on_pre_player_mined_item(event)
  -- Dock inventories should never return their contents to the player
  -- because all their items are duplicates from the spidertron's inventory
  local dock = event.entity
  if dock and dock.name:sub(0, 19) == "sp-spidertron-dock-" then
    local dock_inventory = dock.get_inventory(defines.inventory.chest)  ---@cast dock_inventory -?
    dock_inventory.clear()
  end
end

local function animate_dock(dock)
  local frames = 32
  local speed = 0.5
  local tick = game.tick

  local dock_name = dock.name

  -- Schedule future replacement once closing animation has finished
  if dock_name == "sp-spidertron-dock-closing" then
    local schedule = storage.scheduled_dock_replacements[tick + frames - 2] or {}
    table.insert(schedule, dock)
    storage.scheduled_dock_replacements[tick + frames - 2] = schedule
  end

  -- Don't draw animation for already-closed dock
  if dock_name == "sp-spidertron-dock" then return end

  -- Draw animation
  -- frame = ((tick * speed) + offset) % frames
  animation_offset = -(tick * speed) % frames
  animation_speed = 1
  if dock_name == "sp-spidertron-dock-closing" then
    animation_offset = frames - animation_offset - 1
    animation_speed = -1
  end

  rendering.draw_animation{
    animation = "sp-spidertron-dock-door",
    target = {
      entity = dock,
      offset = util.by_pixel_hr(-9, -46),
    },
    surface = dock.surface,
    time_to_live = frames,
    animation_offset = animation_offset,
    --animation_offset = (tick * (speed - speed') + offset) % #frames`
    --animation_offset = new_dock_name == "sp-spidertron-dock" and (game.tick % 8) or (8 - (game.tick % 8)),
    animation_speed = animation_speed,
    render_layer = "higher-object-under",
  }
end

---@param dock LuaEntity
---@param new_dock_name string
---@return LuaEntity
function replace_dock(dock, new_dock_name)
  if new_dock_name == "sp-spidertron-dock" and dock.name ~= "sp-spidertron-dock-closing" then
    -- Need to use temporary dock entity whilst closing animation is playing
    new_dock_name = "sp-spidertron-dock-closing"
  end

  local health = dock.health
  local last_user = dock.last_user
  local wire_connectors = dock.get_wire_connectors(true)
  local to_be_deconstructed = dock.to_be_deconstructed()

  local circuit_read_contents
  local control_behavior = dock.get_control_behavior()  ---@cast control_behavior LuaContainerControlBehavior
  if control_behavior then
    circuit_read_contents = control_behavior.read_contents
  end

  local players_with_gui_open = {}
  for _, player in pairs(game.connected_players) do
    if player.opened == dock then
      table.insert(players_with_gui_open, player)
    end
  end

  old_dock = dock
  dock = dock.surface.create_entity({
    name = new_dock_name,
    position = dock.position,
    force = dock.force,
    spill = false,
    create_build_effect_smoke = false,
    fast_replace = true
  })  --[[@as LuaEntity]]

  dock.health = health
  dock.last_user = last_user

  local new_wire_connectors = dock.get_wire_connectors(true)
  for i, connector in pairs(wire_connectors) do
    for _, connection in pairs(connector.connections) do
      local target = connection.target
      local origin = connection.origin
      new_wire_connectors[i].connect_to(target, false, origin)
    end
  end

  if to_be_deconstructed then
    dock.order_deconstruction(dock.force)
  end

  if circuit_read_contents ~= nil then
    local new_control_behavior = dock.get_or_create_control_behavior()  ---@cast new_control_behavior LuaContainerControlBehavior
    new_control_behavior.read_contents = circuit_read_contents
  end

  for _, player in pairs(players_with_gui_open) do
    if player.valid then
      player.opened = dock
    end
  end

  script.register_on_object_destroyed(dock)
  old_dock.destroy()

  animate_dock(dock)

  return dock
end

---@param inventory LuaInventory
---@return ItemFilter[]
local function get_filters(inventory)
  if not inventory.is_filtered() then return {} end
  local filters = {}
  for i = 1, #inventory do
    local filter = inventory.get_filter(i)
    if filter then
      filters[i] = filter
    end
  end
  return filters
end

---@param inventory LuaInventory
---@return InventoryContents
local function get_contents_dict(inventory)
  local contents_list = inventory.get_contents()
  local contents_dict = {}
  for _, item in pairs(contents_list) do
    local contents_by_quality = contents_dict[item.name] or {}
    contents_by_quality[item.quality] = item.count + (contents_by_quality[item.quality] or 0)
    contents_dict[item.name] = contents_by_quality
  end
  return contents_dict
end

---@param dock LuaEntity
---@param spidertron LuaEntity
---@param previous_contents {items: InventoryContents, filters: ItemFilter[]}
---@return {items: InventoryContents, filters: ItemFilter[]}
local function update_dock_inventory(dock, spidertron, previous_contents)
  local previous_items = previous_contents.items
  local previous_filters = previous_contents.filters
  if not previous_items then
    -- Pre-2.2.7 migration
    ---@diagnostic disable-next-line: cast-local-type
    previous_items = previous_contents
    previous_filters = {}
  end

  local spidertron_inventory = spidertron.get_inventory(defines.inventory.spider_trunk)  ---@cast spidertron_inventory -?
  local spidertron_contents = get_contents_dict(spidertron_inventory)
  local spidertron_filters = get_filters(spidertron_inventory)

  local dock_inventory = dock.get_inventory(defines.inventory.chest)  ---@cast dock_inventory -?
  local dock_contents = get_contents_dict(dock_inventory)
  local dock_filters = get_filters(dock_inventory)

  -- If Freight Forwarding is installed, we need to spill an container items on the ground because they aren't allowed inside spidertrons
  if storage.freight_forwarding_enabled then
    local is_container = storage.freight_forwarding_container_items
    for item_name, quality_contents in pairs(dock_contents) do
      for quality_name, count in pairs(quality_contents) do
        if is_container[item_name] then
          local position = dock.position
          local removed = dock_inventory.remove({name = item_name, quality = quality_name, count = count})
          if removed > 0 then
            game.print({"freight-forwarding.containers-in-spider-vehicles", "[gps=" .. position.x .. "," .. position.y .. "," .. dock.surface.name .. "]"})
            local spilled = dock.surface.spill_item_stack{
              position = {position.x + 0.25, position.y + 2},
              stack = {name = item_name, count = removed},
              enable_looted = true,
              force = nil,
              allow_belts = false,
            }
            if not next(spilled) then
              game.print("Error: could not spill container from spidertron dock")
            end
          end
        end
      end
    end
  end

  local spidertron_filter_diff = filter_table_diff(spidertron_filters, previous_filters)
  for index, filter in pairs(spidertron_filter_diff) do
    if filter == -1 then
      dock_inventory.set_filter(index, nil)
    else
      dock_inventory.set_filter(index, filter)
    end
  end

  local dock_filter_diff = filter_table_diff(dock_filters, previous_filters)
  for index, filter in pairs(dock_filter_diff) do
    if filter == -1 then
      spidertron_inventory.set_filter(index, nil)
    else
      spidertron_inventory.set_filter(index, filter)
    end
  end

  local spidertron_diff = table_diff(spidertron_contents, previous_items)
  for item_name, quality_table in pairs(spidertron_diff) do
    for quality_name, count in pairs(quality_table) do

      if count > 0 then
        dock_inventory.insert{name = item_name, count = count, quality = quality_name}
      else
        dock_inventory.remove{name = item_name, count = -count, quality = quality_name}
      end
    end
  end

  local dock_diff = table_diff(dock_contents, previous_items)
  for item_name, count in pairs(dock_diff) do
    for quality_name, count in pairs(count) do

      if count > 0 then
        spidertron_inventory.insert{name = item_name, count = count, quality = quality_name}
      else
        spidertron_inventory.remove{name = item_name, count = -count, quality = quality_name}
      end
    end
  end

  spidertron_inventory.sort_and_merge()
  dock_inventory.sort_and_merge()

  local new_spidertron_contents = {items = get_contents_dict(spidertron_inventory), filters = get_filters(spidertron_inventory)}
  --local new_dock_contents = dock_inventory.get_contents()
  --assert(table_equals(new_spidertron_contents, new_dock_contents))  -- TODO Remove for release
  return new_spidertron_contents
end

---@param bounding_box BoundingBox
---@param increase number
---@return BoundingBox
local function increase_bounding_box(bounding_box, increase)
  local left_top = bounding_box.left_top
  local right_bottom = bounding_box.right_bottom
  return {left_top = {x = left_top.x - increase, y = left_top.y - increase}, right_bottom = {x = right_bottom.x + increase, y = right_bottom.y + increase}}
end

---@param dock_data DockData
---@param spidertron LuaEntity
---@return boolean?
local function connect_to_spidertron(dock_data, spidertron)
  if storage.spidertrons_docked[spidertron.unit_number] or spidertron.speed >= 0.1 or spidertron.name == "companion" or spidertron.autopilot_destination then return end

  local inventory = spidertron.get_inventory(defines.inventory.spider_trunk)  ---@cast inventory -?
  local inventory_size = #inventory
  if inventory_size == 0 then return end

  -- Don't connect to spidertrons containing toolbelt equipment, because we will not have a dock with the correct inventory size defined
  local grid = spidertron.grid
  if grid then
    -- Inventory size bonus remains the tick that the toolbelt is removed. This works, and maybe a future `grid.inventory_bonus` would work too
    if inventory_size ~= math.floor(spidertron.prototype.get_inventory_size(defines.inventory.spider_trunk) * (1 + (spidertron.quality.level * 0.3))) then
      for _, player in pairs(spidertron.force.players) do
        -- Only print warning every 2 seconds. This may fail when more than 20 docks are placed...
        if game.tick % 120 == 0 then
          if player.surface == spidertron.surface then
            player.create_local_flying_text{
              text = {"flying-text.spidertron-toolbelts-cannot-be-docked", SPIDERTRON_NAME_CAPITALISED},
              position = dock_data.dock.position,
            }
          end
        end
      end
    return
    end
  end

  -- Check if driver has prevent-docking-when-driving enabled
  local waypoint_info = get_waypoint_info(spidertron)
  if not waypoint_info.on_patrol then  -- Only check for drivers if not in automatic mode
    local driver = spidertron.get_driver()
    if driver then
      if driver.object_name == "LuaEntity" then
        driver = driver.player
      end
      if driver then
        local player_settings = driver.mod_settings
        if player_settings["sp-prevent-docking-when-driving"] and player_settings["sp-prevent-docking-when-driving"].value then
          return
        end
      end
    end
  end

  local new_dock_name = "sp-spidertron-dock-" .. inventory_size
  -- Switch dock entity out for one with the correct inventory size
  local dock = replace_dock(dock_data.dock, new_dock_name)
  dock_data.dock = dock
  storage.spidertron_docks[dock.unit_number] = dock_data

  dock_data.connected_spidertron = spidertron
  storage.spidertrons_docked[spidertron.unit_number] = dock.unit_number
  --game.print("Spidertron docked")
  --surface.create_entity{name = "flying-text", position = dock.position, text = {"flying-text.spidertron-docked"}}

  local spidertron_contents = {items = get_contents_dict(inventory), filters = get_filters(inventory)}
  local dock_inventory = dock.get_inventory(defines.inventory.chest)  ---@cast dock_inventory -?
  for index, filter in pairs(spidertron_contents.filters) do
    dock_inventory.set_filter(index, filter)
  end
  for item_name, quality_dict in pairs(spidertron_contents.items) do
    for quality_name, count in pairs(quality_dict) do
      dock_inventory.insert{name = item_name, count = count, quality = quality_name}
    end
  end
  dock_data.previous_contents = spidertron_contents
  return true
end

---@param dock_data DockData
---@return nil
---@return boolean
local function update_dock(dock_data)
  local dock = dock_data.dock
  local delete = false
  if dock.valid and dock.name ~= "sp-spidertron-dock-closing" then
    local surface = dock.surface
    local spidertron = dock_data.connected_spidertron
    if spidertron and spidertron.valid then
      -- Dock is connected. Check update inventories, then undock if needed
      dock_data.previous_contents = update_dock_inventory(dock, spidertron, dock_data.previous_contents)

      -- 0.1 * 216 ~ 20km/h
      if dock.to_be_deconstructed() or spidertron.speed > 0.2 or spidertron.autopilot_destination or not math2d.bounding_box.collides_with(increase_bounding_box(dock.bounding_box, 1.7), spidertron.bounding_box) then
        -- Spidertron needs to become undocked
        storage.spidertrons_docked[spidertron.unit_number] = nil
       -- surface.create_entity{name = "flying-text", position = dock.position, text = {"flying-text.spidertron-undocked"}}

        dock = replace_dock(dock, "sp-spidertron-dock")
        storage.spidertron_docks[dock.unit_number] = {dock = dock}
        delete = true
      end
    else
      if spidertron then
        -- `spidertron` is not valid
        dock_data = {dock = dock_data.dock}
      end

      -- Check if dock should initiate connection
      if not dock.to_be_deconstructed() then
        local nearby_spidertrons = surface.find_entities_filtered{type = "spider-vehicle", area = increase_bounding_box(dock.bounding_box, 0.4), force = dock.force}
        for _, spidertron in pairs(nearby_spidertrons) do
          local connected = connect_to_spidertron(dock_data, spidertron)
          if connected then
            delete = true
            break
          end
        end
      end
    end
  else
    delete = true
  end
  return nil, delete  -- Deletes dock from global table
end

---@param event EventData.on_tick
local function on_tick(event)
  local schedule = storage.scheduled_dock_replacements[event.tick]
  if schedule then
    for _, dock in pairs(schedule) do
      if dock.valid then
        dock = replace_dock(dock, "sp-spidertron-dock")
        storage.spidertron_docks[dock.unit_number] = {dock = dock}
      end
    end
  end
  if next(storage.spidertron_docks) then
    -- TODO Replace '20' with configurable setting?
    storage.from_k = for_n_of(storage.spidertron_docks, storage.from_k, 20, update_dock)
  end
end

Dock.events = {
  [defines.events.on_pre_player_mined_item] = on_pre_player_mined_item,
  [defines.events.on_built_entity] = on_built,
  [defines.events.on_robot_built_entity] = on_built,
  [defines.events.on_space_platform_built_entity] = on_built,
  [defines.events.script_raised_revive] = on_built,
  [defines.events.script_raised_built] = on_built,
  [defines.events.on_entity_cloned] = on_built,
  [defines.events.on_object_destroyed] = on_object_destroyed,
  [defines.events.on_tick] = on_tick,
}

return Dock