local function convert_remotes_in_inventory(inventory)
  for i = 1,#inventory do
    local item_stack = inventory[i]
    if item_stack.valid_for_read then
      if item_stack.name == "spidertron-remote-patrol" then
        local connected_spidertron = item_stack.connected_entity
        item_stack.set_stack("spidertron-remote")
        item_stack.connected_entity = connected_spidertron
      end
    end
  end
end
script.on_event(defines.events.on_player_main_inventory_changed, function (event) convert_remotes_in_inventory(game.get_player(event.player_index).get_main_inventory()) end)

local function on_remote_cycled(event)
  log("Remote cycled")
  local player = game.get_player(event.player_index)
  local stack = player.cursor_stack
  if stack and stack.valid_for_read then
    local connected_spidertron = stack.connected_entity
    if stack.name == "spidertron-remote" then
      player.cursor_stack.set_stack{name="spidertron-remote-patrol", count=1}
      player.cursor_stack.connected_entity = connected_spidertron
    elseif stack.name == "spidertron-remote-patrol" then
      player.cursor_stack.set_stack{name="spidertron-remote", count=1}
      player.cursor_stack.connected_entity = connected_spidertron
    end
  end
end
script.on_event("remote-cycle-forwards", on_remote_cycled)
script.on_event("remote-cycle-backwards", on_remote_cycled)

function on_player_used_patrol_remote(player, spidertron, position)
  if global.spidertron_on_patrol[spidertron.unit_number] ~= "setup" then
    clear_spidertron_waypoints(spidertron)
    global.spidertron_on_patrol[spidertron.unit_number] = "setup"
    on_patrol = true
  end
  local waypoint_info = get_waypoint_info(spidertron)
  log("Player used patrol remote on position " .. util.positiontostr(position))
  -- Check to see if the new position is close to the first position
  local start_position = waypoint_info.positions[1]
  if start_position and util.distance(position, start_position) < 5 then
    -- Loop is complete
    waypoint_info.positions[1] = start_position
    rendering.destroy(waypoint_info.render_ids[1])
    waypoint_info.render_ids[1] = nil
    on_spidertron_reached_destination(spidertron, true)
    global.spidertron_on_patrol[spidertron.unit_number] = "patrol"
    log("Loop complete")
  else
    table.insert(waypoint_info.positions, position)
    spidertron.autopilot_destination = nil
  end
  update_text(spidertron)  -- Inserts text at the position that we have just added
end