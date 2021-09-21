local function add_alpha(color)
  return {r = color.r, g = color.g, b = color.b, a = 0.75}
end

local function create_render_paths(spidertron, player)
  local waypoint_info = get_waypoint_info(spidertron)

  local color = spidertron.color
  local surface = spidertron.surface.name

  local path_render_ids = {}

  local waypoints = waypoint_info.waypoints
  local number_of_waypoints = #waypoints
  for i, waypoint in pairs(waypoints) do
    local next_waypoint = waypoints[i + 1]
    if i == number_of_waypoints then
      if number_of_waypoints == 2 then
        -- If there are only 2 waypoints, then we don't need to draw the same line twice
        break
      end
      next_waypoint = waypoints[1]
    end

    -- Start and end the line a tile out from the waypoint center
    -- so that it doesn't overlap the number
    local a = waypoint.position
    local b = next_waypoint.position
    local D = util.distance(a, b)
    local d = 1

    if D > d then
      local a2 = {}
      local b2 = {}
      local dD = d / D
      a2.x = a.x + dD * (b.x - a.x)
      a2.y = a.y + dD * (b.y - a.y)

      b2.x = b.x + dD * (a.x - b.x)
      b2.y = b.y + dD * (a.y - b.y)

      local render_id = rendering.draw_line{
        color = color,
        width = 4,
        gap_length = 0.75,
        dash_length = 1.5,
        from = a2,
        to = b2,
        surface = surface,
        players = {player}
      }

      table.insert(path_render_ids, render_id)

      -- Also draw waypoint number like in update_render_text() in case alt-mode is not on
      render_id = rendering.draw_text{
        text = tostring(i),
        surface = spidertron.surface,
        target = {waypoint.position.x, waypoint.position.y},
        color = add_alpha(spidertron.color),
        scale = 5,
        alignment = "center",
        vertical_alignment = "middle",
        players = {player},
      }
      table.insert(path_render_ids, render_id)
    end
  end

  global.path_renders[player.index] = {spidertron = spidertron.unit_number, render_ids = path_render_ids}
end

function update_player_render_paths(player)
  -- Clear up any previous renders
  local path_render_info = global.path_renders[player.index]
  if path_render_info then
    -- There are render ids to cleanup
    local path_render_ids = path_render_info.render_ids
    for _, render_id in pairs(path_render_ids) do
      rendering.destroy(render_id)
    end
    global.path_renders[player.index] = nil
  end

  -- Create new path renders if necessary
  local cursor_stack = player.cursor_stack
  if cursor_stack and cursor_stack.valid_for_read and cursor_stack.name == "sp-spidertron-patrol-remote" then
    local spidertron = cursor_stack.connected_entity
    if spidertron then
      create_render_paths(spidertron, player)
    end
  end
end

script.on_event({defines.events.on_player_cursor_stack_changed, defines.events.on_player_configured_spider_remote},
  function(event)
    local player = game.get_player(event.player_index)
    update_player_render_paths(player)
  end
)

function update_spidertron_render_paths(unit_number)
  for player_index, path_render_info in pairs(global.path_renders) do
    if path_render_info.spidertron == unit_number then
      update_player_render_paths(game.get_player(player_index))
    end
  end
end


function update_render_text(spidertron)
  -- Updates numbered text on ground for given spidertron
  local waypoint_info = get_waypoint_info(spidertron)

  local viewing_players = global.render_players

  -- Re-render all waypoints
  for i, waypoint in pairs(waypoint_info.waypoints) do
    local render_id = waypoint.render_id
    if render_id and rendering.is_valid(render_id) then
      if rendering.get_text(render_id) ~= tostring(i) then
        rendering.set_text(render_id, i)
      end
      if rendering.get_color(render_id) ~= add_alpha(spidertron.color) then
        rendering.set_color(render_id, add_alpha(spidertron.color))
      end
    else
      -- We need to create the text
      render_id = rendering.draw_text{
        text = tostring(i),
        surface = spidertron.surface,
        target = {waypoint.position.x, waypoint.position.y},
        color = add_alpha(spidertron.color),
        scale = 5,
        alignment = "center",
        vertical_alignment = "middle",
        only_in_alt_mode = true,
        players = viewing_players,
      }
      waypoint.render_id = render_id
    end
  end
  update_spidertron_render_paths(spidertron.unit_number)
end


function update_render_players()
  -- Called when a player joins or changes the associated setting
  local render_players = {}
  for _, player in pairs(game.players) do
    if player.mod_settings["sp-show-waypoint-numbers-in-alt-mode"].value then
      table.insert(render_players, player)
    end
  end
  local is_at_least_one_player = not not next(render_players)

  for _, waypoint_info in pairs(global.spidertron_waypoints) do
    for _, waypoint in pairs(waypoint_info.waypoints) do
      local render_id = waypoint.render_id
      if render_id and rendering.is_valid(render_id) then
        rendering.set_players(render_id, render_players)

        -- If render_players is empty then we need to hide the text: empty player list means as visible to all
        rendering.set_visible(render_id, is_at_least_one_player)
      end
    end
  end

  global.render_players = render_players
end
