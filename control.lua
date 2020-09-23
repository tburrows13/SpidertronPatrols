require "util"
require "utils"
require "mode_handling"

--[[
Globals:
global.spidertron_waypoints: indexed by spidertron.unit_number:
  spidertron :: LuaEntity
  waypoints :: array of Waypoint
  Waypoint contains
    position :: Position (Concept)
    wait_time :: int (in seconds)
    condition :: TBD
  render_ids :: auto-generatated from waypoints
  remote :: string - either "spidertron-remote-waypoint" or "spidertron-remote-patrol"

global.spidertron_on_patrol: indexed by spidertron.unit_number
  contains either
  "setup" - when clicking with patrol remote but before it has started moving
  "patrol" - after patrol loop is finished

global.registered_spidertrons: indexed by outcome of script.register_on_entity_destroyed(spidertron)
  contains unit_number

global.stored_remotes: indexed by remote_stack.item_number
  contains a LuaInventory with 1 slot that holds the original remote so that it can be retrieved with a 'dummy' remote

global.selection_gui: indexed by player.index
  frame :: LuaGuiElement
  slider :: LuaGuiElement
  text :: LuaGuiElement
  confirm :: LuaGuiElement
  waypoint :: Waypoint (defined above) - the waypoint that this dialog is setting

global.last_wait_time: indexed by player.index
  int
]]


function get_waypoint_info(spidertron)
  local waypoint_info = global.spidertron_waypoints[spidertron.unit_number]
  if not waypoint_info then
    log("No waypoint info found. Creating blank table")
    global.spidertron_waypoints[spidertron.unit_number] = {spidertron = spidertron, waypoints = {}, render_ids = {}}  -- Entity, list of positions, list of render ids
    waypoint_info = global.spidertron_waypoints[spidertron.unit_number]
  end
  return waypoint_info
end

function clear_spidertron_waypoints(spidertron, unit_number)
  -- Called on Shift-Click or whenever the current autopilot_destination is removed or when the spidertron is removed.
  local waypoint_info
  if spidertron then
    waypoint_info = get_waypoint_info(spidertron)
  else
    waypoint_info = global.spidertron_waypoints[unit_number]
    if not waypoint_info then return end
  end
  if not unit_number then unit_number = spidertron.unit_number end
  log("Clearing spidertron waypoints for unit number " .. unit_number)
  for i, render_id in pairs(waypoint_info.render_ids) do
    rendering.destroy(render_id)
    if global.sub_render_ids[render_id] then
      rendering.destroy(global.sub_render_ids[render_id])
    end
  end
  if spidertron then spidertron.autopilot_destination = nil end
  global.spidertron_waypoints[unit_number] = nil
  global.spidertrons_waiting[unit_number] = nil
end

script.on_event("clear-spidertron-waypoints",
  function(event)
    local player = game.get_player(event.player_index)
    if player.cursor_stack.valid_for_read and player.cursor_stack.type == "spidertron-remote" then
      local remote = player.cursor_stack
      local spidertron = remote.connected_entity
      if spidertron then
        clear_spidertron_waypoints(spidertron)
      end
    end
  end
)

function generate_sub_text(waypoint, spidertron)
  local wait_data = global.spidertrons_waiting[spidertron.unit_number]

  if waypoint.wait_time and waypoint.wait_time > 0 then
    local string = tostring(waypoint.wait_time) .. "s"
    if wait_data and wait_data.waypoint == waypoint then
      string = tostring(wait_data.wait_time) .. "/" .. string
    end
    return string
  end
end

function update_sub_text(waypoint, parent_render_id, spidertron)
  -- TODO check if parent_render_id is valid
  local render_id = global.sub_render_ids[parent_render_id]
  local intended_text = generate_sub_text(waypoint, spidertron)
  if render_id and rendering.is_valid(render_id) then
    -- Check if we need to update it
    local current_text = rendering.get_text(render_id)
    if current_text ~= intended_text then
      if intended_text then
        rendering.set_text(render_id, intended_text)
      else
        rendering.destroy(render_id)
      end
    end
  elseif intended_text then
    -- Create new text
    render_id = rendering.draw_text{text = intended_text, surface = spidertron.surface, target = {waypoint.position.x, waypoint.position.y+0.5}, color = spidertron.color, scale = 2, alignment = "center"}
    global.sub_render_ids[parent_render_id] = render_id
  end
end

function update_text(spidertron)
  -- Updates numbered text on ground for given spidertron
  local waypoint_info = get_waypoint_info(spidertron)
  -- Re-render all waypoints
  for i, waypoint in pairs(waypoint_info.waypoints) do
    local render_id = waypoint_info.render_ids[i]
    if render_id and rendering.is_valid(render_id) then
      if rendering.get_text(render_id) ~= tostring(i) then
        -- Only update text
        rendering.set_text(render_id, i)
      end
    else
      -- We need to create the text
      render_id = rendering.draw_text{text = tostring(i), surface = spidertron.surface, target = {waypoint.position.x, waypoint.position.y - 1.2}, color = spidertron.color, scale = 4, alignment = "center"}
      waypoint_info.render_ids[i] = render_id
    end
    update_sub_text(waypoint, render_id, spidertron)
  end
end

require 'gui'

--script.on_event(player)
local function remote_interface_assign_waypoints(spidertron, waypoints, waypoint_mode, patrol_mode, remote_name)
  for _, waypoint in pairs(waypoints) do
    on_command_issued(nil, spidertron, waypoint.position, waypoint_mode, patrol_mode, waypoint.wait_time, remote_name)
  end
  if patrol_mode then complete_patrol(spidertron) end
end

local on_spidertron_given_new_destination = script.generate_event_name()
remote.add_interface("SpidertronWaypoints", {get_events = function() return {on_spidertron_given_new_destination = on_spidertron_given_new_destination} end,
                                             clear_waypoints = function(unit_number) clear_spidertron_waypoints(nil, unit_number) end,
                                             assign_waypoints = function(spidertron, waypoints) remote_interface_assign_waypoints(spidertron, waypoints, true, false, "spidertron-remote-waypoint") end,
                                             assign_patrol = function(spidertron, waypoints) remote_interface_assign_waypoints(spidertron, waypoints, false, true, "spidertron-remote-patrol") end,
                                            })


function complete_patrol(spidertron)
  -- Called when '1' clicked with the patrol remote or on ALT + Click
  on_spidertron_reached_destination(spidertron, true)
  global.spidertron_on_patrol[spidertron.unit_number] = "patrol"
  log("Loop completed")
end

script.on_event("waypoints-complete-patrol",
  function(event)
    local player = game.get_player(event.player_index)
    local remote = player.cursor_stack
    if remote and remote.valid_for_read and remote.name == "spidertron-remote-patrol" then
      local spidertron = remote.connected_entity
      if spidertron then
        local on_patrol = global.spidertron_on_patrol[spidertron.unit_number]
        local waypoint_info = get_waypoint_info(spidertron)
        if on_patrol and on_patrol == "setup" and waypoint_info.waypoints[1] then
          -- We need to be in setup and there needs to be at least one waypoint
          complete_patrol(spidertron)
        end
      end
    end
  end
)

function on_command_issued(player, spidertron, position, waypoint_mode, patrol_mode, wait_time, remote_name)
  -- Called when remote used and on remote interface call
  local waypoint_info = get_waypoint_info(spidertron)
  local on_patrol = global.spidertron_on_patrol[spidertron.unit_number]

  local reg_id = script.register_on_entity_destroyed(spidertron)
  global.registered_spidertrons[reg_id] = spidertron.unit_number

  if player then  -- Only called when remote used, not with remote interface. Can probably be improved by merging player, waypoint_mode, patrol_mode and remote_name
    remote_name = player.cursor_stack.name
    -- Clear waypoints if remote is different to usual
    if waypoint_info.remote and waypoint_info.remote ~= remote_name then
      clear_spidertron_waypoints(nil, spidertron.unit_number)  -- Prevents it from overwriting autopilot_destination
      waypoint_info = get_waypoint_info(spidertron)  -- Resets back to empty
      global.spidertron_on_patrol[spidertron.unit_number] = nil
    end
  end
  waypoint_info.remote = remote_name

  if not patrol_mode then
    if on_patrol or not waypoint_mode then
      -- Clear all waypoints if we were previously patrolling or waypoints are off
      clear_spidertron_waypoints(nil, spidertron.unit_number)  -- Prevents it from overwriting autopilot_destination
      waypoint_info = get_waypoint_info(spidertron)  -- Resets back to empty
      global.spidertron_on_patrol[spidertron.unit_number] = nil

      -- We are not dealing with it, but we still need to pass on that
      script.raise_event(on_spidertron_given_new_destination, {player_index = player.index, vehicle = spidertron, position = position, success = true, remote = remote_name})

    end
    if #waypoint_info.waypoints > 0 or util.distance(spidertron.position, spidertron.autopilot_destination) > 5 then
      -- The spidertron has to be a suitable distance away, but only if this is the first (i.e. next) waypoint
      log("Player used " .. remote_name .. " on position " .. util.positiontostr(position))
      table.insert(waypoint_info.waypoints, {position = position, wait_time = wait_time})
      --table.insert(waypoint_info.render_ids, false)  -- Will be handled by update_text
      spidertron.autopilot_destination = waypoint_info.waypoints[1].position
      if #waypoint_info.waypoints == 1 then
        -- The spidertron was not already walking towards a waypoint
        script.raise_event(on_spidertron_given_new_destination, {player_index = player.index, vehicle = spidertron, position = waypoint_info.waypoints[1].position, success = true, remote = remote_name})
      end
      update_text(spidertron)
    end

  else
    -- We are in patrol mode
    if global.spidertron_on_patrol[spidertron.unit_number] ~= "setup" then
      clear_spidertron_waypoints(spidertron)
      global.spidertron_on_patrol[spidertron.unit_number] = "setup"
      on_patrol = true
    end
    waypoint_info = get_waypoint_info(spidertron)  -- This line is important because it may have been cleared by the last block
    log("Player used patrol remote on position " .. util.positiontostr(position))
    -- Check to see if the new position is close to the first position
    local start_waypoint = waypoint_info.waypoints[1]
    if start_waypoint and util.distance(position, start_waypoint.position) < 5 then
      -- Loop is complete
      --waypoint_info.waypoints[1].position = start_position
      --rendering.destroy(waypoint_info.render_ids[1])
      --waypoint_info.render_ids[1] = nil
      complete_patrol(spidertron)
    else
      -- Add to patrol
      table.insert(waypoint_info.waypoints, {position = position, wait_time = wait_time})
      spidertron.autopilot_destination = nil
    end
    update_text(spidertron)  -- Inserts text at the position that we have just added
  end

end


script.on_event(defines.events.on_player_used_spider_remote,
  function(event)
    local player = game.get_player(event.player_index)
    local spidertron = event.vehicle
    local position = event.position

    if not event.success then return end

    on_command_issued(player, spidertron, position, player.is_shortcut_toggled("spidertron-remote-waypoint"), player.is_shortcut_toggled("spidertron-remote-patrol"))
  end
)


function on_spidertron_reached_destination(spidertron, patrol_start)
  local waypoint_info = get_waypoint_info(spidertron)
  local on_patrol = global.spidertron_on_patrol[spidertron.unit_number]
  log("Spidertron reached destination at " .. util.positiontostr(waypoint_info.waypoints[1].position))
  local removed_waypoint
  if not patrol_start then
    removed_waypoint = table.remove(waypoint_info.waypoints, 1)
    removed_render_id = table.remove(waypoint_info.render_ids, 1)
  end

  if #waypoint_info.waypoints > 0 then
    if util.distance(spidertron.position, waypoint_info.waypoints[1].position) > 5 then  -- I can remove all lines like this in Factorio 1.1
      spidertron.autopilot_destination = waypoint_info.waypoints[1].position
      -- The spidertron is now walking towards a new waypoint
      script.raise_event(on_spidertron_given_new_destination, {player_index = 1, vehicle = spidertron, position = waypoint_info.waypoints[1].position, success = true, remote = waypoint_info.remote})
    end
  end

  if on_patrol and not patrol_start then
    -- Add reached position to the back of the queue
    table.insert(waypoint_info.waypoints, removed_waypoint)
    table.insert(waypoint_info.render_ids, removed_render_id)
  elseif not on_patrol then
    rendering.destroy(removed_render_id)
    if global.sub_render_ids[removed_render_id] then
      rendering.destroy(global.sub_render_ids[removed_render_id])
    end
  end
  update_text(spidertron)
end

function handle_wait_timers()
  for unit_number, wait_data in pairs(global.spidertrons_waiting) do
    if wait_data.wait_time <= 1 then
      on_spidertron_reached_destination(wait_data.spidertron)
      global.spidertrons_waiting[unit_number] = nil
    else
      wait_data.wait_time = wait_data.wait_time - 1
    end
    update_text(wait_data.spidertron)
  end
end
script.on_nth_tick(60, handle_wait_timers)


local function on_nth_tick()
  for _, waypoint_info in pairs(global.spidertron_waypoints) do
    local spidertron = waypoint_info.spidertron
    local waypoint_queue = waypoint_info.waypoints
    if spidertron and spidertron.valid and not global.spidertrons_waiting[spidertron.unit_number] then
      local on_patrol = global.spidertron_on_patrol[spidertron.unit_number]
      if on_patrol ~= "setup" and #waypoint_queue > 0 then
        -- Check if we have arrived
        if util.distance(spidertron.position, waypoint_queue[1].position) < 5 then
          -- The spidertron has reached its destination (if we aren't in patrol mode or we are but not in setup)
          local wait_time = waypoint_queue[1].wait_time
          if wait_time and wait_time > 0 then
            -- Add to wait queue
            global.spidertrons_waiting[spidertron.unit_number] = {spidertron = spidertron, wait_time = wait_time, waypoint = waypoint_queue[1]}
            update_text(spidertron)
          else
            on_spidertron_reached_destination(spidertron)
          end

        -- Check if we need to clear the queue because something has cancelled the current autopilot_destination
        -- Note that queue is only cleared when not within 2 tiles of destination
        elseif not spidertron.autopilot_destination then
          clear_spidertron_waypoints(spidertron)
        end
      end
    end
  end
end
script.on_nth_tick(10, on_nth_tick)

script.on_event(defines.events.on_entity_destroyed,
  function(event)
    local unit_number = event.unit_number
    local reg_id = event.registration_number
    if contains_key(global.registered_spidertrons, reg_id, true) then
      clear_spidertron_waypoints(nil, unit_number)
      global.spidertron_on_patrol[unit_number] = nil
    end
  end
)

local function settings_changed()
  global.scroll_modes = {"spidertron-remote"}
  if settings.global["spidertron-waypoints-include-waypoint"].value then
    table.insert(global.scroll_modes, "spidertron-remote-waypoint")
  end
  if settings.global["spidertron-waypoints-include-patrol"].value then
    table.insert(global.scroll_modes, "spidertron-remote-patrol")
  end
end
script.on_event(defines.events.on_runtime_mod_setting_changed, settings_changed)

local function spidertron_switched(event)
  -- Called in response to Spidertron Weapon Switcher event
  local previous_unit_number = event.previous_spidertron_unit_number
  local spidertron = event.new_spidertron
  if global.spidertron_waypoints[previous_unit_number] then
    global.spidertron_waypoints[spidertron.unit_number] = global.spidertron_waypoints[previous_unit_number]
    global.spidertron_waypoints[spidertron.unit_number].spidertron = spidertron
    global.spidertron_waypoints[previous_unit_number] = nil
  end

  if global.spidertron_on_patrol[previous_unit_number] then
    global.spidertron_on_patrol[spidertron.unit_number] = global.spidertron_on_patrol[previous_unit_number]
    global.spidertron_on_patrol[previous_unit_number] = nil
  end

  if global.spidertrons_waiting[previous_unit_number] then
    global.spidertrons_waiting[spidertron.unit_number] = global.spidertrons_waiting[previous_unit_number]
    global.spidertrons_waiting[spidertron.unit_number].spidertron = spidertron
    global.spidertrons_waiting[previous_unit_number] = nil
  end

  local reg_id = script.register_on_entity_destroyed(spidertron)
  global.registered_spidertrons[reg_id] = spidertron.unit_number
end

local function connect_to_remote_interfaces()
  if remote.interfaces["SpidertronWeaponSwitcher"] then
    on_spidertron_switched = remote.call("SpidertronWeaponSwitcher", "get_events").on_spidertron_switched
    log("Creating event")
    script.on_event(on_spidertron_switched, spidertron_switched)
  end
end
script.on_load(connect_to_remote_interfaces)

local function setup()
    global.spidertron_waypoints = {}
    global.spidertron_on_patrol = {}
    global.registered_spidertrons = {}
    global.stored_remotes = {}
    global.selection_gui = {}
    global.last_wait_times = {}
    global.spidertrons_waiting = {}
    global.sub_render_ids = {}
    connect_to_remote_interfaces()
    settings_changed()
  end

local function config_changed_setup(changed_data)
  -- Only run when this mod was present in the previous save as well. Otherwise, on_init will run.
  local mod_changes = changed_data.mod_changes
  local old_version
  if mod_changes and mod_changes["SpidertronWaypoints"] and mod_changes["SpidertronWaypoints"]["old_version"] then
    old_version = mod_changes["SpidertronWaypoints"]["old_version"]
  else
    return
  end

  log("Coming from old version: " .. old_version)
  old_version = util.split(old_version, ".")
  for i=1,#old_version do
    old_version[i] = tonumber(old_version[i])
  end

  global.spidertron_on_patrol = global.spidertron_on_patrol or {}
  global.stored_remotes = global.stored_remotes or {}
  global.selection_gui = global.selection_gui or {}
  global.last_wait_times = global.last_wait_times or {}
  global.spidertrons_waiting = global.spidertrons_waiting or {}
  global.sub_render_ids = global.sub_render_ids or {}
  if old_version[1] == 1 then
    if old_version[2] < 2 then
      log("Running pre 1.2 migration")
      -- Run in >=1.2
      global.registered_spidertrons = {}
      -- Clean up 1.1 bug
      rendering.clear("SpidertronWaypoints")
    end
    if old_version[2] < 4 then
      log("Running pre 1.4 migration")
      -- Convert global format
      for unit_number, waypoint_info in pairs(global.spidertron_waypoints) do
        local waypoints = {}
        for i, position in pairs(waypoint_info.positions) do
          waypoints[i] = {}
          waypoints[i].position = position
        end
        global.spidertron_waypoints[unit_number].positions = nil
        global.spidertron_waypoints[unit_number].waypoints = waypoints
      end
    end
  end

  settings_changed()
end

script.on_init(setup)
script.on_configuration_changed(config_changed_setup)

