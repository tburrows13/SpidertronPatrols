util = require "util"
require "scripts.utils"
local remote_interface = require "scripts.remote-interface"
local dock_script = require "scripts.dock"
local patrol_gui = require "scripts.patrol-gui"
spidertron_control = require "scripts.spidertron-control"
require "scripts.waypoint-rendering"

--[[
Globals:
global.spidertron_waypoints: indexed by spidertron.unit_number:
  spidertron :: LuaEntity
  waypoints :: array of Waypoint
  Waypoint contains
    type :: string ("none", "time-passed", "inactivity", "full-inventory", "empty-inventory", "robots-inactive", "passenger-present", "passenger-not-present", "item-count")
    position :: Position (Concept)
    wait_time :: int (in seconds, only with "time-passed" or "inactivity")
    item_count_info :: array containing
      item_name :: string
      condition :: int (index of condition_dropdown_contents)
      count :: int
    [TBC "item-count" condition info]
    render_id :: int
  current_index :: int (index of waypoints)
  tick_arrived :: int (only set when at a waypoint)
  tick_inactive :: int (only used whilst at an "inactivity" waypoint)
  previous_inventories :: table (only used whilst at an "inactivity" waypoint)
  on_patrol :: bool
]]


function get_waypoint_info(spidertron)
  local waypoint_info = global.spidertron_waypoints[spidertron.unit_number]
  if not waypoint_info then
    log("No waypoint info found. Creating blank table")
    global.spidertron_waypoints[spidertron.unit_number] = {
      spidertron = spidertron,
      waypoints = {},
      render_ids = {},
      current_index = 1,
      on_patrol = false
    }
    waypoint_info = global.spidertron_waypoints[spidertron.unit_number]
  end
  return waypoint_info
end

function clear_spidertron_waypoints(spidertron, unit_number)
  -- Called on custom-input or whenever the current autopilot_destination is removed or when the spidertron is removed.
  -- Pass in either `spidertron` or `unit_number`
  local waypoint_info
  if spidertron then
    waypoint_info = get_waypoint_info(spidertron)
    spidertron.autopilot_destination = nil
  else
    waypoint_info = global.spidertron_waypoints[unit_number]
    if not waypoint_info then return end
  end
  if not unit_number then unit_number = spidertron.unit_number end
  log("Clearing spidertron waypoints for unit number " .. unit_number)
  for _, waypoint in pairs(waypoint_info.waypoints) do
    rendering.destroy(waypoint.render_id)
    --[[if global.sub_render_ids[render_id] then
      rendering.destroy(global.sub_render_ids[render_id])
    end]]
  end
  waypoint_info.waypoints = {}
  patrol_gui.update_gui_schedule(waypoint_info)
  update_spidertron_render_paths(unit_number)
  global.spidertron_waypoints[unit_number] = nil
end

script.on_event("sp-delete-all-waypoints",
  function(event)
    local player = game.get_player(event.player_index)
    if player.cursor_stack.valid_for_read and player.cursor_stack.type == "spidertron-remote" then
      local remote = player.cursor_stack
      local spidertron = remote.connected_entity
      if spidertron then
        clear_spidertron_waypoints(spidertron)
        spidertron.autopilot_destination = nil
      end
    end
  end
)



-- Detect when the player cancels a spidertron's autopilot_destination
script.on_event({"move-right-custom", "move-left-custom", "move-up-custom", "move-down-custom"},
  function(event)
    local player = game.get_player(event.player_index)
    local vehicle = player.vehicle
    if vehicle and vehicle.type == "spider-vehicle" and player.render_mode == defines.render_mode.game then  -- Render mode means player isn't in map view...
      local waypoint_info = get_waypoint_info(vehicle)
      waypoint_info.on_patrol = false
      patrol_gui.update_gui_switch(waypoint_info)
      --clear_spidertron_waypoints(vehicle)
    end
  end
)

script.on_event(defines.events.on_entity_destroyed,
  function(event)
    local unit_number = event.unit_number
    clear_spidertron_waypoints(nil, unit_number)
    dock_script.on_entity_destroyed(event)
  end
)

script.on_event(defines.events.on_tick,
  function(event)
    dock_script.on_tick()
    patrol_gui.update_gui_highlights()
  end
)

--[[
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
]]

local function setup()
    global.spidertron_waypoints = {}     -- Indexed by spidertron.unit_number
    global.path_renders = {}  -- Indexed by player.index
    global.wait_time_defaults = {}

    global.spidertron_docks = {}
    global.spidertrons_docked = {}

    global.open_gui_elements = {}
    global.player_highlights = {}  -- Indexed by player.index

    remote_interface.connect_to_remote_interfaces()
    --settings_changed()
  end

local function config_changed_setup(changed_data)
  -- Only run when this mod was present in the previous save as well. Otherwise, on_init will run.
  local mod_changes = changed_data.mod_changes
  local old_version
  if mod_changes and mod_changes["SpidertronPatrols"] and mod_changes["SpidertronPatrols"]["old_version"] then
    old_version = mod_changes["SpidertronPatrols"]["old_version"]
  else
    return
  end

  log("Coming from old version: " .. old_version)
  old_version = util.split(old_version, ".")
  for i=1, #old_version do
    old_version[i] = tonumber(old_version[i])
  end

  -- Example usage for migrations
  if old_version[1] == 2 then
    if old_version[2] < 1 then
      -- Pre 2.1
      global.path_renders = {}
      global.player_highlights = {}
    end
  end

  --settings_changed()
end

script.on_init(setup)
script.on_configuration_changed(config_changed_setup)
