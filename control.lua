util = require "util"
require "scripts.utils"
remote_interface = require "scripts.remote-interface"
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
    type :: string ("none", "time-passed", "inactivity", "full-inventory", "empty-inventory", "robots-inactive", "passenger-present", "passenger-not-present", "item-count", "circuit-condition")
    position :: Position (Concept)
    wait_time? :: int (in seconds, only with "time-passed" or "inactivity")
    item_count_info? :: array containing
      item_name :: string or SignalID (depending on if type is "item-count" or "circuit-condition")
      condition :: int (index of condition_dropdown_contents)
      count :: int
    render_id :: int
  current_index :: int (index of waypoints)
  tick_arrived? :: int (only set when at a waypoint)
  tick_inactive? :: int (only used whilst at an "inactivity" waypoint)
  previous_inventories? :: table (only used whilst at an "inactivity" waypoint)
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
    dock_script.on_tick(event)
    patrol_gui.update_gui_highlights()
    spidertron_control.handle_spider_stopping()
  end
)

script.on_event(defines.events.on_runtime_mod_setting_changed,
  function(event)
    if event.setting_type == "runtime-per-user" then
      if event.setting == "sp-show-waypoint-numbers-in-alt-mode" then
        update_render_players()
      end
    end
  end
)
script.on_event(defines.events.on_player_joined_game, update_render_players)

local function set_base_version()
  local version = game.active_mods["base"]
  version = util.split(version, ".")
  for i=1, #version do
    version[i] = tonumber(version[i])
  end
  global.base_version = version
end

local function setup()
  set_base_version()
  global.spidertron_waypoints = {}     -- Indexed by spidertron.unit_number
  global.path_renders = {}  -- Indexed by player.index

  global.spidertron_docks = {}
  global.spidertrons_docked = {}
  global.scheduled_dock_replacements = {}

  global.open_gui_elements = {}
  global.player_highlights = {}  -- Indexed by player.index

  remote_interface.connect_to_remote_interfaces()
  update_render_players()
  --settings_changed()
  end

local function config_changed_setup(changed_data)
  set_base_version()
  -- Only run when this mod was present in the previous save as well. Otherwise, on_init will run.
  local mod_changes = changed_data.mod_changes
  local old_version
  if mod_changes and mod_changes["SpidertronPatrols"] and mod_changes["SpidertronPatrols"]["old_version"] then
    old_version = mod_changes["SpidertronPatrols"]["old_version"]
  else
    return
  end

  -- Close all spidertron GUIs
  for _, player in pairs(game.players) do
    if player.opened_gui_type == defines.gui_type.entity then
      local entity = player.opened
      if entity.type == "spider-vehicle" then
        player.opened = nil
      end
    end
  end

  global.wait_time_defaults = nil

  log("Coming from old version: " .. old_version)
  old_version = util.split(old_version, ".")
  for i=1, #old_version do
    old_version[i] = tonumber(old_version[i])
  end

  if old_version[1] == 2 then
    if old_version[2] < 1 then
      -- Pre 2.1
      global.path_renders = {}
      global.player_highlights = {}
    end
    if old_version[2] < 2 then
      -- Pre 2.2
      reset_render_objects()
    end
    if old_version[2] < 3 then
      -- Pre 2.3
      global.scheduled_dock_replacements = {}
    end
  end
end

script.on_init(setup)
script.on_configuration_changed(config_changed_setup)

function reset_render_objects()
  rendering.clear("SpidertronPatrols")
  global.path_renders = {}
  update_render_players()
  for _, waypoint_info in pairs(global.spidertron_waypoints) do
    local spidertron = waypoint_info.spidertron
    if spidertron and spidertron.valid then
      update_render_text(waypoint_info.spidertron)
    end
  end
  for _, player in pairs(game.players) do
    update_player_render_paths(player)
  end
end

commands.add_command("reset-sps-render-objects",
  "Clears all render objects (numbers and lines on the ground) created by Spidertron Patrols and recreates only the objects that are supposed to exist. Use whenever render objects are behaving unexpectedly or have been permanently left behind due to a mod bug or incompatibility.",
  function()
    reset_render_objects()
    game.print("Render objects reset")
  end
)
