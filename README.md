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
- Toggle waypoint mode with *Alt + O*, via shortcut, or *Shift + Scroll Down* whilst holding a remote
- Toggle patrol mode with *Alt + P*, via shortcut, or *Shift + Scroll Up* whilst holding a remote  
- With patrol remote in hand, click to mark the position sequence
- Click on the **1** to finish the sequence and the spidertron will start following it
- Thank you to [danatron1](https://www.reddit.com/r/factorio/comments/iitlvi/i_made_a_mod_that_allows_you_to_set_waypoints/g3dzt1h) for creating the patrol remote icon (which also doubles up as a cool thumbnail!)

-----
Recommendations
-----

- *Shift + Scroll* controls are derived from **Blueprint book next** and **Blueprint book previous**. If you have rebound these controls, this mod's shift-scrolling will not work
- Remove *Shift + Mouse wheel up* and *Shift + Mouse wheel down* from **Zoom in** and **Zoom out** controls
- Use [Equipment Grid Logistic Module](https://mods.factorio.com/mod/EquipmentGridLogisticModule) to autofill your patrolling spidertrons

-----
Known Bugs / Limitations
-----

- Spidertron remotes are removed from the quickbar when they are switched to patrol remotes when **With patrol mode** is chosen in the startup settings (this setting can be changed at any time, but requires a game restart)

-----
Future Updates
-----

- Compatibility with [Spidertron squad control](https://mods.factorio.com/mod/Spider_Control) (you can follow the development of that [here](https://github.com/npc-strider/spidertron-squad-control/pull/1))
- Allow pausing at certain waypoints
- Fix remotes being removed from quickbar when playing with both remote icons (I don't think that this is possible to fix with the current mod API)
- Better looking shortcut icons (help would be appreciated!)

-----
Mod Compatibility
-----

The only base game prototype modification is changing `icon` and `icon_mipmaps` for `spidertron-remote` depending on a startup setting.

For compatibility with other mods that use `on_player_used_spider_remote`, this mod provides a remote interface. The new event `on_spidertron_given_new_destination` is raised when a spidertron has been given a new `autopilot_target`, and comes with an `event` table containing `player_index`, `vehicle`, `position`, and `success` (always set to true). Note that `event.player` does not exist. The following example should be placed in `on_init` and `on_load`:

```
if game.active_mods["SpidertronWaypoints"] then
    local event_ids = remote.call("SpidertronWaypoints", "get_event_ids")
    local on_spidertron_given_new_destination = event_ids.on_spidertron_given_new_destination
    script.on_event(on_spidertron_given_new_destination, function(event)
        -- Do stuff here instead of in `on_player_used_spider_remote`
    end)
```

Please let me know if you need help implementing this or if you need additional compatibility features.