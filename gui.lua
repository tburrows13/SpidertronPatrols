local slider_values = {1, 2, 5, 10, 15, 20, 30, 45, 60, 120, 240, 600}
slider_values[0] = 0

local function slider_value_index(input_value)
  for i, slider_value in pairs(slider_values) do
    if input_value == slider_value then
      return i
    elseif input_value < slider_value then
      return i - 1
    end
  end
  return #slider_values
end

local function create_gui(player, waypoint_info, default_config)
  local gui_elements = {}

  local caption
  if waypoint_info == "default" then
    caption = {"waypoints-gui.default-title"}
    gui_elements.waypoint = "default"
  else
    caption = {"waypoints-gui.standard-title", #waypoint_info.waypoints}
    gui_elements.waypoint = waypoint_info.waypoints[#waypoint_info.waypoints]
    gui_elements.spidertron = waypoint_info.spidertron
  end

  local frame = player.gui.screen.add{type="frame", caption=caption, direction="vertical"}
  frame.force_auto_center()
  gui_elements.frame = frame

  local vertical_flow_1 = frame.add{type="frame", style="item_and_count_select_background", direction="horizontal"}
  vertical_flow_1.add{type="label", style="heading_2_label", caption={"waypoints-gui.type"}, tooltip={"waypoints-gui.inactivity-explanation-tooltip"}}
  vertical_flow_1.add{type="empty-widget", style="waypoints_empty_filler"}
  gui_elements.switch = vertical_flow_1.add{type="switch",
                                            style="waypoints_switch_padding",
                                            name="waypoints-countdown-type-switch",
                                            left_label_caption={"waypoints-gui.time-passed"},
                                            right_label_caption={"waypoints-gui.inactivity"},
                                            allow_none_state = false,
                                            switch_state = default_config.wait_type,
                                            tooltip={"waypoints-gui.inactivity-explanation-tooltip"}
                                          }

  --length_select_frame.add{type="line", direction="horizontal"}

  local vertical_flow_2 = frame.add{type="frame", style="item_and_count_select_background", direction="horizontal"}
  gui_elements.slider = vertical_flow_2.add{type="slider",
                           name="waypoints-condition-selector-slider",
                           minimum_value=0,
                           maximum_value=#slider_values,
                           value=slider_value_index(tonumber(default_config.wait_time)),
                           value_step=1,
                           discrete_slider=true,
                           style="notched_slider"
                          }
  gui_elements.text = vertical_flow_2.add{type="textfield",
                                          name="waypoints-condition-selector-text",
                                          style="slider_value_textfield",
                                          numeric=true,
                                          allow_decimal=false,
                                          allow_negative=false,
                                          lose_focus_on_confirm=true,
                                          text=default_config.wait_time
                                        }
  vertical_flow_2.add{type="label", caption={"waypoints-gui.seconds"}}
  gui_elements.confirm = vertical_flow_2.add{type="sprite-button",
                                             name="waypoints-condition-selector-confirm",
                                             mouse_button_filter={"left"},
                                             sprite="utility/check_mark",
                                             style="item_and_count_select_confirm"
                                            }
  return gui_elements
end

local function should_open_default(remote)
  -- Open numbered dialog (return false) when player is holding any remote and there is at least one waypoint and if spidertron_on_patrol is set then it must equal "setup"
  if remote and remote.valid_for_read and remote.type == "spidertron-remote" then
    local spidertron = remote.connected_entity
    if spidertron and (not global.spidertron_on_patrol[spidertron.unit_number] or global.spidertron_on_patrol[spidertron.unit_number] == "setup") then
      -- If we are in patrol mode, we need to be in setup
      local waypoint_info = get_waypoint_info(spidertron)
      if waypoint_info.waypoints[1]then
        -- There is at least one waypoint
        return false
      end
    end
  end
  return true
end

script.on_event("waypoints-change-wait-conditions",
  function(event)
    local player = game.get_player(event.player_index)
    local remote = player.cursor_stack
    if global.selection_gui[player.index] then
      local gui_elements = global.selection_gui[player.index]
      if gui_elements and player.opened == gui_elements.frame then
        save_and_exit_gui(player, gui_elements)
      end
    elseif not global.selection_gui[player.index] then
      if should_open_default(remote) then
        -- Default configuration GUI
        if not global.wait_time_defaults[player.index] then
          config_data = {wait_time = 0, wait_type = "left"}
          global.wait_time_defaults[player.index] = config_data
        else
          config_data = global.wait_time_defaults[player.index]
        end
        local gui_elements = create_gui(player, "default", config_data)
        global.selection_gui[player.index] = gui_elements
        player.opened = gui_elements.frame
      else
        -- Numbered waypoint configuration GUI
        local waypoint_info = get_waypoint_info(remote.connected_entity)  -- Validity checks have already been done in should_open_default
        local config_data
        local waypoint = waypoint_info.waypoints[#waypoint_info.waypoints]
        if waypoint.wait_time_manually_set then
          config_data = {wait_time = waypoint.wait_time, wait_type = waypoint.wait_type}
        elseif not global.wait_time_defaults[player.index] then
          config_data = {wait_time = 0, wait_type = "left"}
          global.wait_time_defaults[player.index] = config_data
        else
          config_data = global.wait_time_defaults[player.index]
        end
        local gui_elements = create_gui(player, waypoint_info, config_data)
        global.selection_gui[player.index] = gui_elements
        player.opened = gui_elements.frame
      end
    end
  end
)

script.on_event("waypoints-change-default-wait-conditions",
  function(event)
    -- Largely copied from above function
    local player = game.get_player(event.player_index)
    if global.selection_gui[player.index] then
      local gui_elements = global.selection_gui[player.index]
      if gui_elements and player.opened == gui_elements.frame then
        save_and_exit_gui(player, gui_elements)
      end
    elseif not global.selection_gui[player.index] then
      if not global.wait_time_defaults[player.index] then
        config_data = {wait_time = 0, wait_type = "left"}
        global.wait_time_defaults[player.index] = config_data
      else
        config_data = global.wait_time_defaults[player.index]
      end
      local gui_elements = create_gui(player, "default", config_data)
      global.selection_gui[player.index] = gui_elements
      player.opened = gui_elements.frame
    end
  end
)

--[[
script.on_event(defines.events.on_gui_switch_state_changed,
  function(event)
    local gui_elements = global.selection_gui[event.player_index]
    if gui_elements and event.element == gui_elements.switch then
      local switch_state = gui_elements.switch.switch_state
    end
  end
)
]]

-- Slider moved
script.on_event(defines.events.on_gui_value_changed,
  function(event)
    local gui_elements = global.selection_gui[event.player_index]
    if gui_elements and event.element == gui_elements.slider then
      gui_elements.text.text = tostring(slider_values[gui_elements.slider.slider_value])
    end
  end
)

-- Text box confirmed (not the whole gui)
script.on_event(defines.events.on_gui_confirmed,
  function(event)
    local gui_elements = global.selection_gui[event.player_index]
    if gui_elements and event.element == gui_elements.text then
      local text = gui_elements.text.text
      if text == "" then
        text = "0"
      end
      value = tonumber(text)
      gui_elements.slider.slider_value = slider_value_index(value)
    end
  end
)

function save_and_exit_gui(player, gui_elements)
  local wait_time = gui_elements.text.text
  local switch_state = gui_elements.switch.switch_state

  gui_elements.frame.destroy()
  global.selection_gui[player.index] = nil

  local waypoint = gui_elements.waypoint

  if waypoint == "default" then
    global.wait_time_defaults[player.index] = {wait_time = tonumber(wait_time), wait_type = switch_state}
  else

    waypoint.wait_type = switch_state

    log("Wait time set to " .. wait_time .. " at position " .. util.positiontostr(waypoint.position))
    waypoint.wait_time = tonumber(wait_time)

    waypoint.wait_time_manually_set = true
    if gui_elements.spidertron and gui_elements.spidertron.valid then  -- if condition for guis created in 1.4.3
      update_text(gui_elements.spidertron)
    end
  end
end

script.on_event(defines.events.on_gui_click,
  function(event)
    local player = game.get_player(event.player_index)
    local gui_elements = global.selection_gui[event.player_index]
    if gui_elements and event.element == gui_elements.confirm then
      save_and_exit_gui(player, gui_elements)
    end
  end
)
script.on_event("waypoints-gui-confirm",  -- Called when the player presses 'E'
  function(event)
    local player = game.get_player(event.player_index)
    local gui_elements = global.selection_gui[event.player_index]
    if gui_elements and player.opened == gui_elements.frame then
      save_and_exit_gui(player, gui_elements)
    end
  end
)

script.on_event(defines.events.on_gui_closed,
  function(event)
    local gui_elements = global.selection_gui[event.player_index]
    if gui_elements and event.element == gui_elements.frame then
      gui_elements.frame.destroy()
      global.selection_gui[event.player_index] = nil
    end
  end
)

--[[script.on_event("waypoints-close-gui",
  function(event)
    -- Called when 'e' is pressed - do not apply setting
    game.print("Pressed E")
    gui_elements = global.selection_gui[event.player_index]
    if gui_elements and event.element == gui_elements.confirm then
      gui_elements.frame.destroy()
      global.selection_gui[event.player_index] = nil
    end
  end
)]]
