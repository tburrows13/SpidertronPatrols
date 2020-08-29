Spidertron Waypoints
==================

Have more control over your spidertrons with waypoints! Click with the remote to add a waypoint and shift-click to clear all waypoints.

![Demonstration gif](https://i.imgur.com/lSvtJP8.gif)

-----
Mod developers
-----

For compatibility with other mods that use `on_player_used_spider_remote`, this mod provides a remote interface. The new event `on_spidertron_given_new_destination` is raised when a spidertron is being assigned to a new waypoint, and comes with an `event` table containing `player_index`, `vehicle`, `position`, and `success` (always set to true). Note that `event.player` does not exist. The following example should be placed in `on_init` and `on_load`:

```
if game.active_mods["SpidertronWaypoints"] then
    local event_ids = remote.call("SpidertronWaypoints", "get_event_ids")
    local on_spidertron_given_new_destination = event_ids.on_spidertron_given_new_destination
    script.on_event(on_spidertron_given_new_destination, function(event)
        -- Do stuff here instead of in `on_player_used_spider_remote`
    end)
```

Please let me know if you need help implementing this or if you need additional compatability features.