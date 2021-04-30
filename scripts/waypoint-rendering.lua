script.on_event({defines.events.on_player_cursor_stack_changed, defines.events.on_player_configured_spider_remote},
  function(event)
    return
    --[[
    local player = game.get_player(event.player_index)
    local cursor_stack = player.cursor_stack
    if cursor_stack and cursor_stack.valid_for_read and cursor_stack.name == "sp-spidertron-remote-patrol" then
      local spidertron = cursor_stack.connected_entity
      if spidertron then
        local waypoint_info = get_waypoint_info(spidertron)
        local visualisation_info = {player = player, waypoint_entities = {}}
        local waypoint_entities = visualisation_info.waypoint_entities
        for _, waypoint in pairs(waypoint_info.waypoints) do
          local waypoint_entity = spidertron.surface.create_entity{name = "sp-spidertron-waypoint",
                                           --bounding_box = generate_bounding_box(waypoint.position, 1),
                                           position = waypoint.position,
                                           force = spidertron.force,
                                          player = player}
                                           --box_type = "train-visualization",
                                           --render_player_index = 65535}
          table.insert(waypoint_entities, waypoint_entity)
          --global.waypoint_entities[waypoint_entity.unit_number] = player.index
        end

        global.waypoint_visualisations[player.index] = visualisation_info
      end

    else
      -- Clear up
      local waypoint_visualisations = global.waypoint_visualisations[player.index]
      if waypoint_visualisations then
        for _, waypoint_entity in pairs(waypoint_visualisations.waypoint_entities) do
          --global.waypoint_entities[waypoint_entity.unit_number] = nil
          waypoint_entity.destroy()
        end
      end
    end]]
  end
)

local function on_waypoint_added(player, spidertron, position)
  local waypoint_visualisations = global.waypoint_visualisations[player.index]

  local waypoint_entities = waypoint_visualisations.waypoint_entities
  local waypoint_entity = spidertron.surface.create_entity{name = "sp-spidertron-waypoint",
                            --bounding_box = generate_bounding_box(waypoint.position, 1),
                            position = position,
                            force = spidertron.force,
                          player = player}
                            --box_type = "train-visualization",
                            --render_player_index = 65535}
  table.insert(waypoint_entities, waypoint_entity)


end

return {on_waypoint_added = on_waypoint_added}