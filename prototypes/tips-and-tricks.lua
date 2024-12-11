data:extend{
  {
    type = "tips-and-tricks-item-category",
    name = "spidertron-patrols",
    order = "-[spidertron-patrols]"
  },
  {
    type = "tips-and-tricks-item",
    name = "spidertron-patrols",
    tag = "[entity=spidertron][item=sp-spidertron-patrol-remote]",
    category = "spidertron-patrols",
    is_title = true,
    order = "a",
    trigger = {type = "build-entity", entity = "spidertron", match_type_only = true},
    simulation = {
      mods = {"SpidertronEnhancements", "SpidertronPatrols"},
      init =
      [[
        require("__core__/lualib/story")
        player = game.simulation.create_test_player{name = "big k"}
        player.teleport({0, 2.5})
        game.simulation.camera_player = player
        game.simulation.camera_alt_info = true
        game.simulation.camera_zoom = 1
        game.surfaces[1].build_checkerboard{{-22, -11}, {22, 11}}
        game.simulation.camera_player_cursor_position = player.position
    
        spider = game.surfaces[1].create_entity{name = "spidertron", position = {-8, 1.5}, force = "player", create_build_effect_smoke = false}
    
        local story_table =
        {
          {
            {
              name = "start",
              condition = story_elapsed_check(0.5),
            },
            {
              condition = function() return game.simulation.move_cursor({position = {spider.position.x, spider.position.y - 1.5}}) end,
              action = function() game.simulation.control_press{control = "spidertron-enhancements-spidertron-patrol-pipette", notify = true} end
            },
            { condition = story_elapsed_check(0.5) },
            {
              condition = function() return game.simulation.move_cursor({position = {11, 6.5}}) end,
              action = function() game.simulation.control_press{control = "use-item", notify = true} end
            },
            { condition = story_elapsed_check(0.5) },
            {
              condition = function() return game.simulation.move_cursor({position = {11, -6.5}, speed = 0.35}) end,
              action = function() game.simulation.control_press{control = "use-item", notify = true} end
            },
            { condition = story_elapsed_check(0.5) },
            {
              condition = function() return game.simulation.move_cursor({position = {-11, -6.5}, speed = 0.35}) end,
              action = function() game.simulation.control_press{control = "use-item", notify = true} end
            },
            { condition = story_elapsed_check(0.5) },
            {
              condition = function() return game.simulation.move_cursor({position = {-16, 8.5}, speed = 0.35}) end,
              action = function() game.simulation.control_press{control = "use-item", notify = true} end
            },
            { condition = story_elapsed_check(1.5) },
            {
              condition = function() return game.simulation.move_cursor({position = {-11, 6.5}, speed = 0.35}) end,
              action = function() game.simulation.control_press{control = "sp-replace-previous-waypoint", notify = true} end
            },
            { condition = story_elapsed_check(1.5) },
            {
              condition = function() return game.simulation.move_cursor({position = {0, 0}}) end,
              action = function() game.simulation.control_press{control = "sp-toggle-spidertron-automatic-manual", notify = true} end
            },
            {
              condition = story_elapsed_check(11),
              action = function() game.simulation.control_press{control = "sp-toggle-spidertron-automatic-manual", notify = true} end
            },
            {
              condition = story_elapsed_check(2),
              action = function() game.simulation.control_press{control = "sp-delete-all-waypoints", notify = true} end
            },
            {
              condition = story_elapsed_check(1),
              action = function()
                player.clear_cursor()
                story_jump_to(storage.story, "start")
              end
            }
          }
        }
        tip_story_init(story_table)
      ]]
    }
  },
  {
    type = "tips-and-tricks-item",
    name = "spidertron-patrols-dock",
    tag = "[entity=sp-spidertron-dock]",
    category = "spidertron-patrols",
    order = "b",
    indent = 1,
    --trigger = {type = "build-entity", entity = "spidertron", match_type_only = true},
    simulation = {
      mods = {"SpidertronEnhancements", "SpidertronPatrols"},
      init_update_count = 20,
      init = [[
        game.surfaces[1].create_entities_from_blueprint_string
        {
          string = "0eNrNmN1uozAQhd/F16bC5ichr1JFEYFJ1ioxyDbdzUZ597VBadot7Y5ne9FIkRKMvxkfPJ4jLmzfjTAYpR3bXJhqem3Z5vHCrDrqugvXdH0CtmGH2rrEmVrboTcu2UPn2JUzpVv4xTbiyhfm2CGxg2rBONPrpO2bp1dT5HXLGWinnII55vTnvNPjaQ/GM/mNo/RBaT+UND/AOsbZ0Fs/rdchlkclq4eCs7P/IR+KKcJ8/86Cc0ofbbjPwKl/ht3oxzoHBtqdcnDyQ4e6s8DZfHnO5Ja/A+iSoasd+KBNPwaVRJpydurbcEPtkg7qKaUXIbbXoMVfa5GEtWTfdC0Zf7Mnur72T3hhIeXrZbTKQDOP5py58xDm96MbxrCN3sXI42JISoyCf7a338fK3z6Y19EW6CWVLjH0VSQ9i8p9HUmXUfSKSkcpI1KqNDi8iMSLKG2EpOJx2d9rdz92T4nS1h/Oi5WVfggWcomcx5MzHDmyTkXcXhclFY9TfIXVRchIxdfxZKTikRUqiijFZWSFiriDVwoqHvVApaSKg8NnkfgyTpycisdlX+D6dti7//AGSn/QtmUZF0NSYqzQfk1U/+PXnBlh0S+uCQnIr0ygIjhW8V0daxpnJwXFTmaC6vgEprQySfU1OHxGdWU4fE71NTh8Ee8+BKoXZmR7gEucYA+Qia+pfQqXeEXtsih8nlL7FA4v4nqIIPSQXBKOcPGFR3h+L2k77q2rp4gLpZZOscUiI0cxyk8I99KEzstnVJOABnM8+83u13GoG1hIahbeb2xfF4cDmJ1Vv2E6/m+f8Prop38ioWc8+rUW3CdbbP3VoEsoqJc3W5w9+94y0YtSVnlVFf6bi7XP+A97tEWc",
          position = {-2, 2}
        }
        -- Above command doesn't raise events, so place docks and spidertron-with-patrol-tags separately
        local surface = game.surfaces[1]
        local spiderling_ghost = surface.create_entity{name = "entity-ghost", inner_name = "sp-spiderling", position = {3, 0}, force = "player"}
        spiderling_ghost.tags = {spidertron_patrol_data = {hide_gui = false, waypoints = {{item_condition_info = {condition = 4, count = 200, elem = {name = "steel-plate", quality = "normal"}}, position = {x = -5.3, y = 0.3}, type = "item-count"}, {position = {x = 4.3, y = 0.3}, type = "empty-inventory"}}}}
        local _, spiderling = spiderling_ghost.revive{raise_revive = true}
        remote.call("SpidertronPatrols", "set_on_patrol", spiderling, true)
    
        surface.create_entity{name = "sp-spidertron-dock", position = {-5, 0}, force = "player", raise_built = true}
        surface.create_entity{name = "sp-spidertron-dock", position = {4, 0}, force = "player", raise_built = true}

        game.simulation.camera_alt_info = true
        game.simulation.camera_position = {0, 0.5}

        game.forces.player.bulk_inserter_capacity_bonus = 11
      ]]
    }
  },
  {
    type = "tips-and-tricks-item",
    name = "spidertron-patrols-gui",
    tag = "[item=sp-spidertron-patrol-remote]",
    category = "spidertron-patrols",
    order = "c",
    indent = 1,
    --trigger = {type = "build-entity", entity = "spidertron", match_type_only = true},
    simulation = {
      mods = {"SpidertronEnhancements", "SpidertronPatrols"},
      --init_update_count = 20,
      init = [[
        local surface = game.surfaces[1]
        local spiderling_ghost = surface.create_entity{name = "entity-ghost", inner_name = "sp-spiderling", position = {3, 0}, force = "player"}
        spiderling_ghost.tags = {spidertron_patrol_data = {hide_gui = false, waypoints = {
          {item_condition_info = {condition = 4, count = 200, elem = {name = "steel-plate", quality = "normal"}}, position = {x = -5, y = 0}, type = "item-count"},
          {position = {x = 4, y = -0}, type = "empty-inventory"}
        }}}
        local _, spiderling = spiderling_ghost.revive{raise_revive = true}
        --remote.call("SpidertronPatrols", "set_on_patrol", spiderling, true)
    

        player = game.simulation.create_test_player{name = "Xorimuth"}
        player.teleport({0.5, -7})

        game.simulation.camera_player = player
        game.simulation.camera_alt_info = true
        game.simulation.camera_position = {0, 0.5}

        player.opened = spiderling
      ]]
    }
  },
}