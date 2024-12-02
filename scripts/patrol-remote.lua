local PatrolRemote = {}

---@type table<PlayerIndex, GameTick>
local replace_this_tick = {}  -- Shouldn't desync as long as comparison is only made to current tick

---@param selected LuaEntity?
---@param position MapPosition
---@return MapPosition
local function snap_waypoint_position(selected, position)
  -- Snap position to center of dock, or center of tile
  if selected and (
    selected.name:sub(0, 19) == "sp-spidertron-dock-" or
    (selected.name == "entity-ghost" and selected.ghost_name:sub(0, 19) == "sp-spidertron-dock-")
  ) then
    return selected.position
  else
    return {x = math.floor(position.x) + 0.5, y = math.floor(position.y) + 0.5}
  end
end

script.on_event("sp-replace-previous-waypoint",
  function(event)
    replace_this_tick[event.player_index] = event.tick
  end
)

---@param event EventData.on_player_used_spidertron_remote
local function on_player_used_spidertron_remote(event)
  local player = game.get_player(event.player_index)  ---@cast player -?
  local spidertron = player.spidertron_remote_selection[1]
  -- Prevent remote working on docked spidertrons from Space Spidertron
  if spidertron.name:sub(1, 10) == "ss-docked-" then return end

  local remote = player.cursor_stack

  if remote and remote.valid_for_read and remote.name == "sp-spidertron-patrol-remote" then
    local position = snap_waypoint_position(player.selected, event.position)
    local replace_waypoint = replace_this_tick[event.player_index] == event.tick

    local waypoint_index = storage.remotes_in_cursor[player.index]
    local waypoint_info = get_waypoint_info(spidertron)
    local number_of_waypoints = #waypoint_info.waypoints
    if waypoint_index and waypoint_index ~= -1 then
      waypoint_index = math.min(number_of_waypoints + 1, waypoint_index)
      if replace_waypoint then
        storage.remotes_in_cursor[player.index] = waypoint_index
      else
        storage.remotes_in_cursor[player.index] = waypoint_index + 1
      end
    else
      waypoint_index = number_of_waypoints
    end

    SpidertronControl.on_patrol_command_issued(spidertron, position, waypoint_index, replace_waypoint)
  else
    local waypoint_info = get_waypoint_info(spidertron)
    waypoint_info.on_patrol = false
    PatrolGui.update_gui_switch(waypoint_info)
  end
end

---@param player LuaPlayer
---@param spidertron LuaEntity
---@param waypoint_index WaypointIndex
function PatrolRemote.give_remote(player, spidertron, waypoint_index)
  if not player.is_cursor_empty() then
    local cleared = player.clear_cursor()
    if not cleared then return end
  end
  local cursor = player.cursor_stack
  if not cursor then return end
  cursor.set_stack("sp-spidertron-patrol-remote")
  player.spidertron_remote_selection = {spidertron}

  if waypoint_index then
    storage.remotes_in_cursor[player.index] = waypoint_index
  else
    storage.remotes_in_cursor[player.index] = -1  -- Represents last waypoint
  end
end

PatrolRemote.events = {
  [defines.events.on_player_used_spidertron_remote] = on_player_used_spidertron_remote,
}

return PatrolRemote