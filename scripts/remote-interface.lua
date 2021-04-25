local function remote_interface_assign_waypoints(spidertron, waypoints, waypoint_mode, patrol_mode, remote_name)
  for _, waypoint in pairs(waypoints) do
    local wait_type
    if waypoint.wait_type then
      if waypoint.wait_type == "time_passed" then wait_type = "left" end
      if waypoint.wait_type == "inactivity" then wait_type = "right" end
    end
    on_patrol_command_issued(nil, spidertron, waypoint.position, waypoint_mode, patrol_mode, waypoint.wait_time, wait_type, remote_name)
  end
  if patrol_mode then complete_patrol(spidertron) end
end

local on_spidertron_given_new_destination = script.generate_event_name()
remote.add_interface("SpidertronWaypoints", {get_events = function() return {on_spidertron_given_new_destination = on_spidertron_given_new_destination} end,
                                             clear_waypoints = function(unit_number) clear_spidertron_waypoints(nil, unit_number) end,
                                             assign_waypoints = function(spidertron, waypoints) remote_interface_assign_waypoints(spidertron, waypoints, true, false, "spidertron-remote-waypoint") end,
                                             assign_patrol = function(spidertron, waypoints) remote_interface_assign_waypoints(spidertron, waypoints, false, true, "spidertron-remote-patrol") end,
                                            }
)

return {on_spidertron_given_new_destination = on_spidertron_given_new_destination}