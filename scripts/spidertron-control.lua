-- Handles on_player_used_spider_remote, on_spider_command_completed, and wait conditions

function on_patrol_command_issued(player, spidertron, position)
  -- Called when remote used and on remote interface call
  local waypoint_info = get_waypoint_info(spidertron)
  -- We are in patrol mode
  log("Player used patrol remote on position " .. util.positiontostr(position))

  -- Add to patrol
  if (not player.selected) or player.selected.name ~= "sp-spidertron-waypoint" then
    local waypoint = {position = position, type = "none"}
    --[[if player and global.wait_time_defaults[player.index] then
      waypoint.wait_time = global.wait_time_defaults[player.index].wait_time
      waypoint.wait_type = global.wait_time_defaults[player.index].wait_type
    end]]
    table.insert(waypoint_info.waypoints, waypoint)
    --waypoint_rendering.on_waypoint_added(player, spidertron, position)
  end

  if waypoint_info.on_patrol then
    -- Send the spidertron to current_index waypoint, and add all other waypoints to autopilot_destinations
    local waypoints = waypoint_info.waypoints
    local number_of_waypoints = #waypoints
    local current_index = waypoint_info.current_index
    spidertron.autopilot_destination = waypoints[current_index + 1].position
    --[[for i = 0, number_of_waypoints do
      local index = ((i + current_index) % number_of_waypoints)
      spidertron.add_autopilot_destination(waypoints[index + 1].position)
    end]]
  else
    spidertron.autopilot_destination = nil
  end
  patrol_gui.update_gui_schedule(waypoint_info)
  update_text(spidertron)  -- Inserts text at the position that we have just added

end


script.on_event(defines.events.on_player_used_spider_remote,
  function(event)
    local player = game.get_player(event.player_index)
    local spidertron = event.vehicle
    local position = event.position

    local remote = player.cursor_stack

    if event.success then
      if remote.name == "sp-spidertron-remote-patrol" then
        on_patrol_command_issued(player, spidertron, position)
      else
        --clear_spidertron_waypoints(spidertron)
        local waypoint_info = get_waypoint_info(spidertron)
        waypoint_info.on_patrol = false
        patrol_gui.update_gui_switch(waypoint_info)
      end
    end
  end
)

---------------------------------------------------------------------------------------------------

function on_spidertron_reached_destination(spidertron)
  local waypoint_info = get_waypoint_info(spidertron)

  if waypoint_info.on_patrol then
    local number_of_waypoints = #waypoint_info.waypoints
    if number_of_waypoints > 0 then
      local next_waypoint = ((waypoint_info.current_index + 1) % number_of_waypoints)
      --spidertron.add_autopilot_destination(waypoint_info.waypoints[next_waypoint + 1].position)
      spidertron.autopilot_destination = waypoint_info.waypoints[next_waypoint + 1].position
      waypoint_info.current_index = next_waypoint

      patrol_gui.update_gui_schedule(waypoint_info)
      -- The spidertron is now walking towards a new waypoint
      --script.raise_event(remote_interface.on_spidertron_given_new_destination, {player_index = 1, vehicle = spidertron, position = waypoint_info.waypoints[1].position, success = true, remote = waypoint_info.remote})
    end
  end
end

local function was_spidertron_inactive(spidertron, wait_data)
  local old_trunk = wait_data.previous_trunk
  local new_trunk = spidertron.get_inventory(defines.inventory.spider_trunk).get_contents()
  local old_ammo = wait_data.previous_ammo
  local new_ammo = spidertron.get_inventory(defines.inventory.spider_ammo).get_contents()

  if (not old_trunk) or (not table_equals(old_trunk, new_trunk)) or (not old_ammo) or (not table_equals(old_ammo, new_ammo)) then
    wait_data.previous_trunk = table.deepcopy(new_trunk)
    wait_data.previous_ammo = table.deepcopy(new_ammo)
    return false
  end
  return true
end

function handle_wait_timers()
  for unit_number, wait_data in pairs(global.spidertrons_waiting) do
    if wait_data.wait_time <= 1 then
      on_spidertron_reached_destination(wait_data.spidertron)
      global.spidertrons_waiting[unit_number] = nil
    else
      if wait_data.wait_type and wait_data.wait_type == "right" then
        if was_spidertron_inactive(wait_data.spidertron, wait_data) then
          wait_data.wait_time = wait_data.wait_time - 1
        else
          wait_data.wait_time = wait_data.waypoint.wait_time
        end
      else
        wait_data.wait_time = wait_data.wait_time - 1
      end
    end
    update_text(wait_data.spidertron)
  end
end
script.on_nth_tick(60, handle_wait_timers)



script.on_event(defines.events.on_spider_command_completed,
  function(event)
    local spidertron = event.vehicle
    --[[local waypoint_info = global.spidertron_waypoints[spidertron.unit_number]
    if waypoint_info then
      local waypoints = waypoint_info.waypoints

      -- The spidertron has reached its destination (if we aren't in patrol mode or we are but not in setup)
      if waypoints[1] then
        local wait_time = waypoints[1].wait_time
        local wait_type = waypoints[1].wait_type or "left"
        if wait_time and wait_time > 0 then
          -- Add to wait queue
          global.spidertrons_waiting[spidertron.unit_number] = {spidertron = spidertron, wait_time = wait_time, wait_type = wait_type, waypoint = waypoints[1]}
          update_text(spidertron)
        else]]
          on_spidertron_reached_destination(spidertron)
        --[[end
      end
    end]]
  end
)
