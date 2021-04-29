local util = require "util"
require "scripts.utils"
require "scripts.mode_handling"
local waypoint_rendering = require "scripts.waypoint-rendering"
local remote_interface = require "scripts.remote-interface"
local dock_script = require "scripts.dock"
local patrol_gui = require "scripts.patrol-gui"
local spidertron_control = require "scripts.spidertron-control"

--[[
Globals:
global.spidertron_waypoints: indexed by spidertron.unit_number:
  spidertron :: LuaEntity
  waypoints :: array of Waypoint
  Waypoint contains
    type :: string ("none", "time-passed", "inactivity", "full-inventory", "empty-inventory", "robots-inactive", "passenger-present", "passenger-not-present", "item-count")
    position :: Position (Concept)
    wait_time :: int (in seconds, only with "time-passed" or "inactivity")
    [TBC "item-count" condition info]
  current_index :: int (index of waypoints)
  tick_arrived :: int (only set when at a waypoint)
  tick_inactive :: int (only used whilst at an "inactivity" waypoint)
  previous_inventories :: table (only used whilst at an "inactivity" waypoint)
  on_patrol :: bool
  [TBC render_ids :: auto-generatated from waypoints]

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
  -- Called on Shift-Click or whenever the current autopilot_destination is removed or when the spidertron is removed.
  -- Pass in either `spidertron` or `unit_number`
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

  -- TODO Remove waypoint visualisations

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
        spidertron.autopilot_destination = nil
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
    if waypoint.wait_type and waypoint.wait_type == "right" then
      string = string .. " inactivity"
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
        rendering.set_color(render_id, spidertron.color)  -- In case the color has changed as well
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
        rendering.set_color(render_id, spidertron.color)  -- In case the color has changed as well
      end
    else
      -- We need to create the text
      render_id = rendering.draw_text{text = tostring(i), surface = spidertron.surface, target = {waypoint.position.x, waypoint.position.y - 1.2}, color = spidertron.color, scale = 4, alignment = "center"}
      waypoint_info.render_ids[i] = render_id
    end
    update_sub_text(waypoint, render_id, spidertron)
  end
end

--require 'gui'






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

local function setup()
    global.spidertron_waypoints = {}
    global.waypoint_visualisations = {}
    global.selection_gui = {}
    global.spidertrons_waiting = {}
    global.sub_render_ids = {}
    global.wait_time_defaults = {}
    global.spidertron_docks = {}
    global.spidertrons_docked = {}
    global.open_gui_elements = {}
    remote_interface.connect_to_remote_interfaces()
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
  for i=1, #old_version do
    old_version[i] = tonumber(old_version[i])
  end

  -- Example usage for migrations
  --if old_version[1] == 1 then
  --  if old_version[2] < 2 then

  settings_changed()
end

script.on_init(setup)
script.on_configuration_changed(config_changed_setup)
