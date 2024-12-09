-- Handles on_player_used_spidertron_remote, on_spider_command_completed, and wait conditions

local SpidertronControl = {}

---@param condition uint
---@param a integer
---@param b integer
---@return boolean?
local function check_condition(condition, a, b)
  -- Using list order: {">", "<", "=", "≥", "≤", "≠"}
  if condition == 1 then
    return a > b
  elseif condition == 2 then
    return a < b
  elseif condition == 3 then
    return a == b
  elseif condition == 4 then
    return a >= b
  elseif condition == 5 then
    return a <= b
  elseif condition == 6 then
    return a ~= b
  end
end

---@param spidertron LuaEntity
---@param position MapPosition
---@param index WaypointIndex?
---@param replace boolean?
function SpidertronControl.on_patrol_command_issued(spidertron, position, index, replace)
  -- Called when remote used and on remote interface call
  local waypoint_info = get_waypoint_info(spidertron)
  -- We are in patrol mode
  --log("Player used patrol remote on position " .. util.positiontostr(position))

  -- Add to patrol
  if not index then index = #waypoint_info.waypoints end
  if replace and next(waypoint_info.waypoints) then
    local waypoint = waypoint_info.waypoints[index]
    waypoint.position = position
    waypoint_info.waypoints[index] = waypoint
  else
    local waypoint = {position = position, type = "none"}
    table.insert(waypoint_info.waypoints, index + 1, waypoint)
  end

  if waypoint_info.on_patrol then
    -- Send the spidertron to current_index waypoint, and add all other waypoints to autopilot_destinations
    local waypoints = waypoint_info.waypoints
    --local number_of_waypoints = #waypoints
    local current_index = waypoint_info.current_index
    spidertron.autopilot_destination = waypoints[current_index].position
  else
    spidertron.autopilot_destination = nil
  end
  PatrolGui.update_gui_schedule(waypoint_info)
  WaypointRendering.update_render_text(spidertron)  -- Inserts text at the position that we have just added
end


---------------------------------------------------------------------------------------------------

---@param spidertron LuaEntity
---@param old_inventories unknown
---@return boolean
local function was_spidertron_inactive(spidertron, old_inventories)
  local old_trunk = old_inventories.trunk
  local old_ammo = old_inventories.ammo
  local new_trunk = spidertron.get_inventory(defines.inventory.spider_trunk).get_contents()
  local new_ammo = spidertron.get_inventory(defines.inventory.spider_ammo).get_contents()

  if not old_trunk or not old_ammo or not table_equals(old_trunk, new_trunk) or not table_equals(old_ammo, new_ammo) then
    old_inventories.trunk = table.deepcopy(new_trunk)
    old_inventories.ammo = table.deepcopy(new_ammo)
    return false
  end
  return true
end

---@param spidertron LuaEntity
---@param next_index WaypointIndex?
function SpidertronControl.go_to_next_waypoint(spidertron, next_index)
  local waypoint_info = get_waypoint_info(spidertron)

  local number_of_waypoints = #waypoint_info.waypoints
  if number_of_waypoints > 0 then
    -- Nil some data that is only needed whilst at a waypoint
    waypoint_info.tick_arrived = nil
    waypoint_info.tick_inactive = nil
    waypoint_info.previous_inventories = nil
    waypoint_info.stopped = nil
    waypoint_info.last_distance = nil

    next_index = next_index or ((waypoint_info.current_index) % number_of_waypoints) + 1
    local next_position = waypoint_info.waypoints[next_index].position
    spidertron.autopilot_destination = next_position
    waypoint_info.current_index = next_index

    PatrolGui.update_gui_button_states(waypoint_info)
    -- The spidertron is now walking towards a new waypoint
    script.raise_event("on_spidertron_given_new_destination", {vehicle = spidertron, position = next_position, success = true})
  end
end

function on_tick()
  -- Handles spider stopping
  for _, waypoint_info in pairs(storage.spidertron_waypoints) do
    if waypoint_info.on_patrol and waypoint_info.tick_arrived and not waypoint_info.stopped and waypoint_info.spidertron.valid then
      local spidertron = waypoint_info.spidertron
      local waypoint = waypoint_info.waypoints[waypoint_info.current_index]
      local waypoint_position = waypoint.position

      local distance = util.distance(spidertron.position, waypoint_position)
      local speed = spidertron.speed

      if speed < 0.005 then
        -- Spidertron has stopped
        if distance > 2 then
          -- Spidertron is too far away
          spidertron.teleport(waypoint_position)
        end
        waypoint_info.stopped = true
      else
        local last_distance = waypoint_info.last_distance
        if distance < 0.3 or (last_distance and distance > last_distance) or speed > 0.4 then
          -- We are either very close, getting further away, or going so fast that we need to stop ASAP
          spidertron.stop_spider()
          waypoint_info.last_distance = nil
        else
          waypoint_info.last_distance = distance
        end
      end
    end
  end
end

local function handle_wait_timers()
  for _, waypoint_info in pairs(storage.spidertron_waypoints) do
    if waypoint_info.on_patrol and waypoint_info.tick_arrived and waypoint_info.spidertron.valid then
      -- Spidertron is waiting
      local spidertron = waypoint_info.spidertron
      local waypoint = waypoint_info.waypoints[waypoint_info.current_index]
      local waypoint_type = waypoint.type

      if waypoint_type == "none" then
        -- Can happen if waypoint type is changed whilst spidertron is at waypoint
        SpidertronControl.go_to_next_waypoint(spidertron)
      elseif waypoint_type == "time-passed" or waypoint_type == "submerge" then
        if (game.tick - waypoint_info.tick_arrived) >= waypoint.wait_time * 60 then
          SpidertronControl.go_to_next_waypoint(spidertron)
        end
      elseif waypoint_type == "inactivity" then
        if was_spidertron_inactive(spidertron, waypoint_info.previous_inventories) then
          if (game.tick - waypoint_info.tick_inactive) >= waypoint.wait_time * 60 then
            SpidertronControl.go_to_next_waypoint(spidertron)
          end
        else
          waypoint_info.tick_inactive = game.tick
        end
      elseif waypoint_type == "full-inventory" then
        if spidertron.get_inventory(defines.inventory.spider_trunk).is_full() then
          SpidertronControl.go_to_next_waypoint(spidertron)
        end
      elseif waypoint_type == "empty-inventory" then
        if spidertron.get_inventory(defines.inventory.spider_trunk).is_empty() then
          SpidertronControl.go_to_next_waypoint(spidertron)
        end
      elseif waypoint_type == "item-count" then
        local inventory = spidertron.get_inventory(defines.inventory.spider_trunk)  ---@cast inventory -?
        local item_condition_info = waypoint.item_condition_info  ---@cast item_condition_info -?
        local item_count = inventory.get_item_count(item_condition_info.elem) or 0
        if check_condition(item_condition_info.condition, item_count, item_condition_info.count) then
          SpidertronControl.go_to_next_waypoint(spidertron)
        end
      elseif waypoint_type == "fuel-full" then
        local fuel_inventory = spidertron.get_fuel_inventory()
        if fuel_inventory then
          if fuel_inventory.is_full() then
            SpidertronControl.go_to_next_waypoint(spidertron)
          end
        else
          -- Spidertron prototype no longer allows fuel, so reset its waypoint type
          waypoint.type = "none"
          SpidertronControl.go_to_next_waypoint(spidertron)
        end
      elseif waypoint_type == "circuit-condition" then
        local circuit_condition_info = waypoint.circuit_condition_info  ---@cast circuit_condition_info -?
        local dock_unit_number = storage.spidertrons_docked[spidertron.unit_number]
        if dock_unit_number then
          local dock = storage.spidertron_docks[dock_unit_number].dock
          if dock and dock.valid and circuit_condition_info.elem and circuit_condition_info.elem.name then
            local signal_count = dock.get_signal(circuit_condition_info.elem, defines.wire_connector_id.circuit_red, defines.wire_connector_id.circuit_green)
            if check_condition(circuit_condition_info.condition, signal_count, circuit_condition_info.count) then
              SpidertronControl.go_to_next_waypoint(spidertron)
            end
          end
        end
      elseif waypoint_type == "robots-inactive" then
        local logistic_cell = spidertron.logistic_cell
        if logistic_cell then
          local logistic_network = logistic_cell.logistic_network
          -- Always wait some time in case "Enable logistics while moving" is false
          if (game.tick - waypoint_info.tick_arrived) >= 120 and (not logistic_network or not next(logistic_network.construction_robots)) then
            SpidertronControl.go_to_next_waypoint(spidertron)
          end
        else
          SpidertronControl.go_to_next_waypoint(spidertron)
        end
      elseif waypoint_type == "passenger-present" then
        if spidertron.get_driver() or spidertron.get_passenger() then
          SpidertronControl.go_to_next_waypoint(spidertron)
        end
      elseif waypoint_type == "passenger-not-present" then
        if not (spidertron.get_driver() or spidertron.get_passenger()) then
          SpidertronControl.go_to_next_waypoint(spidertron)
        end
      end
    end
  end
end
script.on_nth_tick(5, handle_wait_timers)

---@param event EventData.on_spider_command_completed
local function on_spider_command_completed(event)
  local spidertron = event.vehicle
  local waypoint_info = get_waypoint_info(spidertron)
  if waypoint_info.on_patrol then
    local waypoints = waypoint_info.waypoints
    local waypoint = waypoints[waypoint_info.current_index]
    local waypoint_type = waypoint.type

    script.raise_event("on_spidertron_patrol_waypoint_reached", {
      spidertron = spidertron,
      waypoint = waypoint,
    })

    if waypoint_type == "none" or ((waypoint_type == "time-passed" or waypoint_type == "inactivity") and waypoint.wait_time == 0) then
      SpidertronControl.go_to_next_waypoint(spidertron)
    else
      waypoint_info.previous_inventories = {}
      waypoint_info.tick_arrived = game.tick
      PatrolGui.update_gui_button_states(waypoint_info)
    end
  end
end

---@param event EventData.on_entity_settings_pasted
local function on_entity_settings_pasted(event)
  local source = event.source
  local destination = event.destination
  if source.type == "spider-vehicle" and destination.type == "spider-vehicle" then

    -- Erase render ids from receiving spidertron
    local destination_waypoint_info = get_waypoint_info(destination)
    for _, waypoint in pairs(destination_waypoint_info.waypoints) do
      waypoint.render.destroy()
    end

    local waypoint_info = util.table.deepcopy(get_waypoint_info(source))
    waypoint_info.on_patrol = destination_waypoint_info.on_patrol
    waypoint_info.spidertron = destination
    waypoint_info.tick_arrived = nil
    waypoint_info.tick_inactive = nil
    waypoint_info.previous_inventories = nil

    -- Erase all render objects so that new ones can be recreated by WaypointRendering.update_render_text
    for _, waypoint in pairs(waypoint_info.waypoints) do
      waypoint.render = nil
    end

    storage.spidertron_waypoints[destination.unit_number] = waypoint_info
    PatrolGui.update_gui_schedule(waypoint_info)
    WaypointRendering.update_render_text(destination)  -- Inserts text at the position that we have just added
  end
end


SpidertronControl.events = {
  [defines.events.on_tick] = on_tick,
  [defines.events.on_spider_command_completed] = on_spider_command_completed,
  [defines.events.on_entity_settings_pasted] = on_entity_settings_pasted,
}

return SpidertronControl