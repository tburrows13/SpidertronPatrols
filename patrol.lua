
--[[local function get_previous_quickbar(player)
  local quickbar_slots = {}
  for i = 1, 100 do
    quickbar_slots[i] = player.get_quick_bar_slot(i)
  end
  return quickbar_slots
end

local function fill_in_quickbar(player, previous_quickbar, new_stack)
  for i = 1, 100 do
    if previous_quickbar[i] and not player.get_quick_bar_slot(i) then
      -- The quickbar filter has been lost since last check, therefore it contained the replaced item
      player.set_quick_bar_slot(i, new_stack)
    end
  end
end]]


--[[local function settings_changed()
  global.use_patrol_remote = settings.startup["spidertron-waypoints-use-patrol-remote"].value

end
script.on_event(defines.events.on_runtime_mod_setting_changed, settings_changed)]]

local function convert_remote(stack, old_name, new_name, player)
  if stack and stack.valid_for_read and stack.name == old_name then
    if stack.name == "spidertron-remote" then
      -- Save the actual remote into a temp inventory
      local connected_spidertron = stack.connected_entity
   
      --local previous_quickbar = get_previous_quickbar(player)
      --player.clean_cursor()
      local inventory = game.create_inventory(1)
      local temporary_stack = inventory[1]

      temporary_stack.transfer_stack(stack)
      stack.set_stack{name=new_name, count=1}
      stack.connected_entity = connected_spidertron
      --fill_in_quickbar(player, previous_quickbar, stack)
      global.stored_remotes[stack.item_number] = inventory
      log("Added inventory for item number " .. stack.item_number)

    elseif stack.name == "spidertron-remote-patrol-2" then
      -- Retrieve the actual remote from the temp inventory
      local item_number = stack.item_number
      local inventory = global.stored_remotes[item_number]
      if not inventory then
        log("Could not find inventory for item number " .. item_number)
        stack.set_stack{name=new_name, count=1}
        return
      end
      stack.clear()
      stack.transfer_stack(inventory[1])
      inventory.destroy()
      global.stored_remotes[item_number] = nil
      log("Clearing inventory for item number " .. item_number)

    end
  end

end

local function shortcut_pressed(player_index, shortcut_name)
  -- Toggle the shortcuts
  local player = game.get_player(player_index)
  local stack = player.cursor_stack

  if shortcut_name == "waypoints-patrol-mode" then
    -- Swap out remotes if need be
    if player.is_shortcut_toggled("waypoints-patrol-mode") then
      convert_remote(stack, "spidertron-remote-patrol-2", "spidertron-remote", player)
    else
      convert_remote(stack, "spidertron-remote", "spidertron-remote-patrol-2", player)
    end
  end

  if contains({"waypoints-patrol-mode", "waypoints-waypoint-mode"}, shortcut_name) then
    player.set_shortcut_toggled(shortcut_name, not player.is_shortcut_toggled(shortcut_name))
  end

end
script.on_event(defines.events.on_lua_shortcut, function(event) shortcut_pressed(event.player_index, event.prototype_name) end)
script.on_event("waypoints-patrol-mode", function(event) shortcut_pressed(event.player_index, "waypoints-patrol-mode") end)
script.on_event("waypoints-waypoint-mode", function(event) shortcut_pressed(event.player_index, "waypoints-waypoint-mode") end)

local function press_if_holding_remote(player_index, shortcut_name)
  local player = game.get_player(player_index)
  local stack = player.cursor_stack
  if stack and stack.valid_for_read then
    if contains({"spidertron-remote", "spidertron-remote-patrol-2"}, stack.name) then
      shortcut_pressed(player_index, shortcut_name)
    end
  end
end
script.on_event("waypoints-patrol-mode-click", function(event) press_if_holding_remote(event.player_index, "waypoints-patrol-mode") end)
script.on_event("waypoints-patrol-mode-scroll", function(event) press_if_holding_remote(event.player_index, "waypoints-patrol-mode") end)
script.on_event("waypoints-waypoint-mode-click", function(event) press_if_holding_remote(event.player_index, "waypoints-waypoint-mode") end)
script.on_event("waypoints-waypoint-mode-scroll", function(event) press_if_holding_remote(event.player_index, "waypoints-waypoint-mode") end)

--script.on_event("pick-item-custom", function(event) game.print("Pickted item! " .. serpent.block(event)) end)


local function convert_remotes_in_inventory(inventory)
  for i = 1,#inventory do
    local stack = inventory[i]
    convert_remote(stack, "spidertron-remote-patrol-2", "spidertron-remote", inventory.player_owner)
  end
end
script.on_event(defines.events.on_player_main_inventory_changed, function (event) convert_remotes_in_inventory(game.get_player(event.player_index).get_main_inventory()) end)

script.on_event(defines.events.on_player_cursor_stack_changed,
  function(event)
    local player = game.get_player(event.player_index)
    if player.is_shortcut_toggled("waypoints-patrol-mode") then
      -- Only convert to patrol remote if patrol mode is on
      convert_remote(player.cursor_stack, "spidertron-remote", "spidertron-remote-patrol-2", player)
    end
  end
)

script.on_event(defines.events.on_player_configured_spider_remote,
  function(event)
    local player = game.get_player(event.player_index)
    local remote = player.cursor_stack
    local spidertron = event.vehicle
    if remote.name == "spidertron-remote-patrol-2" then
      -- We need to update the actual stored remote
      global.stored_remotes[remote.item_number][1].connected_entity = spidertron
    end
  end
)

script.on_event("waypoints-disconnect-remote",
  function(event)
    local player = game.get_player(event.player_index)
    local remote = player.cursor_stack
    if remote and remote.valid_for_read and remote.type == "spidertron-remote" then
      remote.connected_entity = nil

      if remote.name == "spidertron-remote-patrol-2" then
        -- We need to update the stored remote
        global.stored_remotes[remote.item_number][1].connected_entity = nil
      end

    end
  end
)


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