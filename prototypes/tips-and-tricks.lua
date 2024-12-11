data:extend{
  {
    type = "tips-and-tricks-item",
    name = "spidertron-patrols",
    tag = "[entity=spidertron][item=sp-spidertron-patrol-remote]",
    category = "spidertron-patrols",
    is_title = true,
    order = "z-a",
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
              condition = story_elapsed_check(1),
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
}