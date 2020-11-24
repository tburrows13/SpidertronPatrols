Spidertron Waypoints
==================

Have more control over your spidertrons with waypoints! Set up your spidertrons with one-time waypoints or permanent patrols. Even though basic waypoints are now available in 1.1, this mod goes far beyond that by adding infinitely-repeating patrols and customizable wait conditions similar to train stations/stops.

![Waypoints gif](https://i.imgur.com/FJW3E7V.gif)

-----
You can see Xterminator's Mod Spotlight here:

[![Xterminator Mod Spotlight](https://img.youtube.com/vi/RggwfbKXqoQ/0.jpg)](https://www.youtube.com/watch?v=RggwfbKXqoQ)

-----
Features
-----

- In waypoint mode, *Click* with the spidertron remote to add a waypoint
- In patrol mode, *Click* to mark the position sequence, then *Click* on the **1** or *Alt + Click* to finish the sequence and the spidertron will start following it
- Press *Y* after placing a waypoint whilst holding a remote to set the countdown duration and type for it
- Wait condition types: **Time passed** will wait for X seconds; **Inactivity** will wait for X seconds of inactivity (i.e. no changes to inventory or ammo)
- Press *Y* at any other time or *Shift + Y* to configure the default wait condition
- *Shift + Left Click* whilst holding a spidertron remote to clear all waypoints for that spidertron
- *Shift + Right Click* whilst holding a spidertron remote to disconnect it from its spidertron
- Switch to direct, waypoint and patrol modes with *Shift + F*, *Shift + C*, *Shift + X* respectively (notice the 'circle' that they make around *WASD*!)
- Cycle through all 3 modes with *Shift + Scroll* or *+* and *-* (you can remove modes from this cycle in the mod settings)
- Switch modes by mouse in the shortcut bar and easily view which mode is active

-----
Recommendations
-----

- *Shift + Scroll* controls are derived from **Blueprint book next** and **Blueprint book previous**. If you have rebound these controls, this mod's shift-scrolling will not work
- Remove *Shift + Mouse wheel up* and *Shift + Mouse wheel down* from **Zoom in** and **Zoom out** controls if you are using the *Shift + Scroll* controls
- Try using 1.1's spidertron logistics tab to autofill your patrolling spidertrons or use with **Inactivity** waypoints to wait until item requests are completed before returning to a building site

-----
Known Bugs / Limitations
-----

- Waypoint markers cannot be seen in map view (not possible to add because it requires [this API addition](https://forums.factorio.com/viewtopic.php?f=28&t=76539&p=510027) - please post there in support of the addition)
- Changing a waypoint's countdown length whilst a spidertron is at that waypoint changes the waypoint text but has no effect on the spidertron's remaining time

-----
Future Updates?
-----

- Compatibility with [Spidertron squad control](https://mods.factorio.com/mod/Spider_Control) (you can follow the development of that [here](https://github.com/npc-strider/spidertron-squad-control/pull/2))

-----
Translation
-----

You can help by translating this mod into your language using [CrowdIn](https://crowdin.com/project/factorio-mods-localization). Any translations made will be included in the next release.

-----
Mod Compatibility
-----

For compatibility with other mods that use `on_player_used_spider_remote`, this mod provides a remote interface. The new event `on_spidertron_given_new_destination` is raised when a spidertron has been given a new `autopilot_target`, and comes with an `event` table containing `player_index`, `vehicle`, `position`, and `success` (always set to true). Note that `event.player` does not exist. The following example should be placed in `on_init` and `on_load`:

```
if game.active_mods["SpidertronWaypoints"] then
    local event_ids = remote.call("SpidertronWaypoints", "get_events")
    local on_spidertron_given_new_destination = event_ids.on_spidertron_given_new_destination
    script.on_event(on_spidertron_given_new_destination, function(event)
        -- Do stuff here instead of in `on_player_used_spider_remote`
    end)
end
```

Additionally, there are remote functions that allow other mods to use waypoints and patrols:

`clear_waypoints(unit_number)`
Clears all waypoints for the spidertron associated with `unit_number`

`assign_waypoints(spidertron, waypoints)`
Sends the spidertron to each waypoint sequentially
Parameters
`spidertron` :: LuaEntity
`waypoints` :: array of tables with keys `position` (Position), `wait_time` (int - default `0`) in seconds and `wait_type` (string - either `"time_passed"` or `"inactivity"` - default `"time_passed"`)

`assign_patrol(spidertron, waypoints)`
Same as `assign_waypoints`, but creates and starts a persistent patrol

Let me know if you plan on using these and I can help you with debugging or adding new features if you need them.

-----

Thank you to [danatron1](https://www.reddit.com/r/factorio/comments/iitlvi/i_made_a_mod_that_allows_you_to_set_waypoints/g3dzt1h) for creating the patrol remote icon (which also doubles up as a cool thumbnail!) and [smokefumus](https://sketchfab.com/smokefumus) for creating the waypoint remote icon.

Check out my other mods: [Spidertron Engineer](https://mods.factorio.com/mod/SpidertronEngineer) and [Spidertron Weapon Switcher](https://mods.factorio.com/mod/SpidertronWeaponSwitcher)