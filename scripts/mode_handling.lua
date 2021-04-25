script.on_event("waypoints-disconnect-remote",
  function(event)
    local player = game.get_player(event.player_index)
    local remote = player.cursor_stack
    if remote and remote.valid_for_read and remote.type == "spidertron-remote" then
      remote.connected_entity = nil
    end
  end
)