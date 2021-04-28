local function remote_interface_assign_waypoints(spidertron, waypoints, waypoint_mode, patrol_mode, remote_name)
  for _, waypoint in pairs(waypoints) do
    local wait_type
    if waypoint.wait_type then
      if waypoint.wait_type == "time_passed" then wait_type = "left" end
      if waypoint.wait_type == "inactivity" then wait_type = "right" end
    end
    on_patrol_command_issued(nil, spidertron, waypoint.position, waypoint_mode, patrol_mode, waypoint.wait_time, wait_type, remote_name)
  end
end

local on_spidertron_given_new_destination = script.generate_event_name()
remote.add_interface("SpidertronWaypoints", {get_events = function() return {on_spidertron_given_new_destination = on_spidertron_given_new_destination} end,
                                             clear_waypoints = function(unit_number) clear_spidertron_waypoints(nil, unit_number) end,
                                             assign_waypoints = function(spidertron, waypoints) remote_interface_assign_waypoints(spidertron, waypoints, true, false, "spidertron-remote-waypoint") end,
                                             assign_patrol = function(spidertron, waypoints) remote_interface_assign_waypoints(spidertron, waypoints, false, true, "spidertron-remote-patrol") end,
                                            }
)

local function spidertron_switched(event)
  -- Called in response to Spidertron Weapon Switcher event
  local previous_unit_number = event.old_spidertron.unit_number
  local spidertron = event.new_spidertron
  if global.spidertron_waypoints[previous_unit_number] then
    global.spidertron_waypoints[spidertron.unit_number] = global.spidertron_waypoints[previous_unit_number]
    global.spidertron_waypoints[spidertron.unit_number].spidertron = spidertron
    global.spidertron_waypoints[previous_unit_number] = nil
  end

  if global.spidertrons_waiting[previous_unit_number] then
    global.spidertrons_waiting[spidertron.unit_number] = global.spidertrons_waiting[previous_unit_number]
    global.spidertrons_waiting[spidertron.unit_number].spidertron = spidertron
    global.spidertrons_waiting[previous_unit_number] = nil
  end

  if global.spidertrons_docked[previous_unit_number] then
    local dock_unit_number = global.spidertrons_docked[previous_unit_number]
    global.spidertrons_docked[spidertron.unit_number] = dock_unit_number
    global.spidertrons_docked[previous_unit_number] = nil
    dock_data = global.spidertron_docks[dock_unit_number]
    if dock_data then
      local connected_spidertron = dock_data.connected_spidertron
      if connected_spidertron then
        global.spidertron_docks[dock_unit_number].connected_spidertron = spidertron
      end
    end
  end

  script.register_on_entity_destroyed(spidertron)
end

local function connect_to_remote_interfaces()
  if remote.interfaces["SpidertronWeaponSwitcher"] then
    on_spidertron_switched = remote.call("SpidertronWeaponSwitcher", "get_events").on_spidertron_switched
    log("Creating event")
    script.on_event(on_spidertron_switched, spidertron_switched)
  end
end
script.on_load(connect_to_remote_interfaces)


return {on_spidertron_given_new_destination = on_spidertron_given_new_destination, connect_to_remote_interfaces = connect_to_remote_interfaces}