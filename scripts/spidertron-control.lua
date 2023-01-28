-- Handles on_player_used_spider_remote, on_spider_command_completed, and wait conditions

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

function on_patrol_command_issued(spidertron, position)
  -- Called when remote used and on remote interface call
  local waypoint_info = get_waypoint_info(spidertron)
  -- We are in patrol mode
  log("Player used patrol remote on position " .. util.positiontostr(position))

  -- Add to patrol
  local waypoint = {position = position, type = "none"}
  table.insert(waypoint_info.waypoints, waypoint)

  if waypoint_info.on_patrol then
    -- Send the spidertron to current_index waypoint, and add all other waypoints to autopilot_destinations
    local waypoints = waypoint_info.waypoints
    local number_of_waypoints = #waypoints
    local current_index = waypoint_info.current_index
    spidertron.autopilot_destination = waypoints[current_index].position
  else
    spidertron.autopilot_destination = nil
  end
  PatrolGui.update_gui_schedule(waypoint_info)
  update_render_text(spidertron)  -- Inserts text at the position that we have just added
end


script.on_event(defines.events.on_player_used_spider_remote,
  function(event)
    if not event.success then return end

    local player = game.get_player(event.player_index)
    local spidertron = event.vehicle
    -- Prevent remote working on docked spidertrons from Space Spidertron
    if spidertron.name:sub(1, 10) == "ss-docked-" then return end

    local position = event.position
    local remote = player.cursor_stack

    if remote.name == "sp-spidertron-patrol-remote" or remote.name == "spidertron-enhancements-temporary-sp-spidertron-patrol-remote" then
      on_patrol_command_issued(spidertron, position)
    else
      local waypoint_info = get_waypoint_info(spidertron)
      waypoint_info.on_patrol = false
      PatrolGui.update_gui_switch(waypoint_info)
    end
  end
)

---------------------------------------------------------------------------------------------------

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


function go_to_next_waypoint(spidertron, next_index)
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
    script.raise_event(remote_interface.on_spidertron_given_new_destination, {player_index = nil, vehicle = spidertron, position = next_position, success = true})
  end
end

function handle_spider_stopping()
  for _, waypoint_info in pairs(global.spidertron_waypoints) do
    if waypoint_info.on_patrol and waypoint_info.tick_arrived and not waypoint_info.stopped then
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

function handle_wait_timers()
  for _, waypoint_info in pairs(global.spidertron_waypoints) do
    if waypoint_info.on_patrol and waypoint_info.tick_arrived then
      -- Spidertron is waiting
      local spidertron = waypoint_info.spidertron
      local waypoint = waypoint_info.waypoints[waypoint_info.current_index]
      local waypoint_type = waypoint.type

      if waypoint_type == "none" then
        -- Can happen if waypoint type is changed whilst spidertron is at waypoint
        go_to_next_waypoint(spidertron)
      elseif waypoint_type == "time-passed" then
        if (game.tick - waypoint_info.tick_arrived) >= waypoint.wait_time * 60 then
          go_to_next_waypoint(spidertron)
        end
      elseif waypoint_type == "inactivity" then
        if was_spidertron_inactive(spidertron, waypoint_info.previous_inventories) then
          if (game.tick - waypoint_info.tick_inactive) >= waypoint.wait_time * 60 then
            go_to_next_waypoint(spidertron)
          end
        else
          waypoint_info.tick_inactive = game.tick
        end
      elseif waypoint_type == "full-inventory" then
        if spidertron.get_inventory(defines.inventory.spider_trunk).is_full() then
          go_to_next_waypoint(spidertron)
        end
      elseif waypoint_type == "empty-inventory" then
        if spidertron.get_inventory(defines.inventory.spider_trunk).is_empty() then
          go_to_next_waypoint(spidertron)
        end
      elseif waypoint_type == "item-count" then
        local inventory = spidertron.get_inventory(defines.inventory.spider_trunk)
        local inventory_contents = inventory.get_contents()
        local item_count_info = waypoint.item_count_info
        local item_count = inventory_contents[item_count_info.item_name] or 0
        if check_condition(item_count_info.condition, item_count, item_count_info.count) then
          go_to_next_waypoint(spidertron)
        end
      elseif waypoint_type == "circuit-condition" then
        local item_count_info = waypoint.item_count_info
        local dock_unit_number = global.spidertrons_docked[spidertron.unit_number]
        if dock_unit_number then
          local dock = global.spidertron_docks[dock_unit_number].dock
          if dock and dock.valid and item_count_info.item_name and item_count_info.item_name.name then
            local signal_count = dock.get_merged_signal(item_count_info.item_name)
            if check_condition(item_count_info.condition, signal_count, item_count_info.count) then
              go_to_next_waypoint(spidertron)
            end
          end
        end
      elseif waypoint_type == "robots-inactive" then
        local logistic_cell = spidertron.logistic_cell
        if logistic_cell then
          local logistic_network = logistic_cell.logistic_network
          -- Always wait some time in case "Enable logistics while moving" is false
          if (game.tick - waypoint_info.tick_arrived) >= 120 and (not logistic_network or not next(logistic_network.construction_robots)) then
            go_to_next_waypoint(spidertron)
          end
        else
          go_to_next_waypoint(spidertron)
        end
      elseif waypoint_type == "passenger-present" then
        if spidertron.get_driver() or spidertron.get_passenger() then
          go_to_next_waypoint(spidertron)
        end
      elseif waypoint_type == "passenger-not-present" then
        if not (spidertron.get_driver() or spidertron.get_passenger()) then
          go_to_next_waypoint(spidertron)
        end
      end
    end
  end
end
script.on_nth_tick(5, handle_wait_timers)


script.on_event(defines.events.on_spider_command_completed,
  function(event)
    local spidertron = event.vehicle
    local waypoint_info = get_waypoint_info(spidertron)
    if waypoint_info.on_patrol then
      local waypoints = waypoint_info.waypoints
      local waypoint = waypoints[waypoint_info.current_index]
      local waypoint_type = waypoint.type

      if waypoint_type == "none" or ((waypoint_type == "time-passed" or waypoint_type == "inactivity") and waypoint.wait_time == 0) then
        go_to_next_waypoint(spidertron)
      else
        waypoint_info.previous_inventories = {}
        waypoint_info.tick_arrived = game.tick
        PatrolGui.update_gui_button_states(waypoint_info)
      end
    end
  end
)


script.on_event(defines.events.on_entity_settings_pasted,
  function(event)
    local source = event.source
    local destination = event.destination
    if source.type == "spider-vehicle" and destination.type == "spider-vehicle" then

      -- Erase render ids from receiving spidertron
      local destination_waypoint_info = get_waypoint_info(destination)
      for _, waypoint in pairs(destination_waypoint_info.waypoints) do
        rendering.destroy(waypoint.render_id)
      end

      local waypoint_info = util.table.deepcopy(get_waypoint_info(source))
      waypoint_info.on_patrol = destination_waypoint_info.on_patrol
      waypoint_info.spidertron = destination
      waypoint_info.tick_arrived = nil
      waypoint_info.tick_inactive = nil
      waypoint_info.previous_inventories = nil

      -- Erase all render ids so that new ones can be recreated by update_render_text
      for _, waypoint in pairs(waypoint_info.waypoints) do
        waypoint.render_id = nil
      end

      global.spidertron_waypoints[destination.unit_number] = waypoint_info
      PatrolGui.update_gui_schedule(waypoint_info)
      update_render_text(destination)  -- Inserts text at the position that we have just added
    end
  end
)

return {go_to_next_waypoint = go_to_next_waypoint, handle_spider_stopping = handle_spider_stopping}