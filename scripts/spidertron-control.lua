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
  end

  if waypoint_info.on_patrol then
    -- Send the spidertron to current_index waypoint, and add all other waypoints to autopilot_destinations
    local waypoints = waypoint_info.waypoints
    local number_of_waypoints = #waypoints
    local current_index = waypoint_info.current_index
    spidertron.autopilot_destination = waypoints[current_index].position
    --[[
    -- Still using 0-based index
    for i = 0, number_of_waypoints do
      local index = ((i + current_index) % number_of_waypoints)
      spidertron.add_autopilot_destination(waypoints[index + 1].position)
    end]]
  else
    spidertron.autopilot_destination = nil
  end
  patrol_gui.update_gui_schedule(waypoint_info)
  update_render_text(spidertron)  -- Inserts text at the position that we have just added

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
        local waypoint_info = get_waypoint_info(spidertron)
        waypoint_info.on_patrol = false
        patrol_gui.update_gui_switch(waypoint_info)
      end
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

    next_index = next_index or ((waypoint_info.current_index) % number_of_waypoints) + 1
    local next_position = waypoint_info.waypoints[next_index].position
    spidertron.autopilot_destination = next_position
    waypoint_info.current_index = next_index

    patrol_gui.update_gui_button_states(waypoint_info)
    -- The spidertron is now walking towards a new waypoint
    --script.raise_event(remote_interface.on_spidertron_given_new_destination, {player_index = nil, vehicle = spidertron, position = next_position, success = true})
  end
end

function handle_wait_timers()
  for _, waypoint_info in pairs(global.spidertron_waypoints) do
    local tick_arrived = waypoint_info.tick_arrived
    if tick_arrived then
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
        -- Only checks the last inventory slot
        local inventory = spidertron.get_inventory(defines.inventory.spider_trunk)
        if inventory.find_empty_stack() == nil then
          local last_stack = inventory[#inventory]
          if last_stack.valid_for_read and last_stack.count == last_stack.prototype.stack_size then
            go_to_next_waypoint(spidertron)
          end
        end
      elseif waypoint_type == "empty-inventory" then
        if spidertron.get_inventory(defines.inventory.spider_trunk).is_empty() then
          go_to_next_waypoint(spidertron)
        end
      elseif waypoint_type == "item-count" then
        -- TODO
      elseif waypoint_type == "robots-inactive" then
        local logistic_network = spidertron.logistic_network
        if logistic_network.all_construction_robots == logistic_network.available_construction_robots then
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
        if waypoint_type == "inactivity" then
          waypoint_info.previous_inventories = {}
        end
        waypoint_info.tick_arrived = game.tick
        patrol_gui.update_gui_button_states(waypoint_info)
      end
    end
  end
)

return {go_to_next_waypoint = go_to_next_waypoint}