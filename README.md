Spidertron Waypoints
==================

Have more control over your spidertrons with waypoints! Set up your spidertrons with one-time waypoints or permanent patrols.

Waypoints
-----
![Waypoints gif](https://i.imgur.com/lSvtJP8.gif)

-----
Patrols
-----
![Patrols gif](https://i.imgur.com/leZ8QTK.gif)

-----
Features
-----

- *Click* with the spidertron remote to add a waypoint
- *Shift-click* to clear all waypoints for that spidertron
- *Shift-scroll* whilst holding a remote to switch to a patrol remote
- With patrol remote in hand, click to mark the position sequence
- Click on the **1** to finish the sequence and the spidertron will start following it

-----
Recommendations
-----

- Remove *Shift + Mouse wheel up* and *Shift + Mouse wheel down* from **Zoom in** and **Zoom out** controls
- Use [Equipment Grid Logistic Module](https://mods.factorio.com/mod/EquipmentGridLogisticModule) to autofill your patrolling spidertrons

-----
Known Bugs / Limitations
-----

- If you place 2 sequential waypoints close to each other (<5 tiles apart) , all waypoints will be lost when the spidertron reaches that area. This is a limitation of the API, and [will be fixed in Factorio 1.1](https://forums.factorio.com/viewtopic.php?f=65&t=88668)
- Spidertron remotes are removed from the quickbar when they are switched to patrol remotes

-----
Future Updates
-----

- Compatibility with [Spidertron squad control](https://mods.factorio.com/mod/Spider_Control) (you can follow the development of that [here](https://github.com/npc-strider/spidertron-squad-control/pull/1))
- Allow pausing at certain waypoints
- Better looking patrol remote (help would be appreciated!)

-----
Mod Compatibility
-----

For compatibility with other mods that use `on_player_used_spider_remote`, this mod provides a remote interface. The new event `on_spidertron_given_new_destination` is raised when a spidertron has been given a new `autopilot_target`, and comes with an `event` table containing `player_index`, `vehicle`, `position`, and `success` (always set to true). Note that `event.player` does not exist. The following example should be placed in `on_init` and `on_load`:

```
if game.active_mods["SpidertronWaypoints"] then
    local event_ids = remote.call("SpidertronWaypoints", "get_event_ids")
    local on_spidertron_given_new_destination = event_ids.on_spidertron_given_new_destination
    script.on_event(on_spidertron_given_new_destination, function(event)
        -- Do stuff here instead of in `on_player_used_spider_remote`
    end)
```

Please let me know if you need help implementing this or if you need additional compatability features.