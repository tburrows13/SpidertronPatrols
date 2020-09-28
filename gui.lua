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

script.on_event("waypoints-change-wait-conditions",
  function(event)
    local player = game.get_player(event.player_index)
    local remote = player.cursor_stack
    if remote and remote.valid_for_read and remote.type == "spidertron-remote" and not global.selection_gui[player.index] then
      local spidertron = remote.connected_entity
      if spidertron then
        local waypoint_info = get_waypoint_info(spidertron)
        if waypoint_info.waypoints[1] and (not player.is_shortcut_toggled("spidertron-remote-patrol") or global.spidertron_on_patrol[spidertron.unit_number] == "setup" )then
          -- There needs to be a 'last waypoint' and if we are in patrol mode, we need to be in setup

          local last_wait_time = global.last_wait_times[player.index] or 0

          local gui_elements = {}
          local frame = player.gui.center.add{type="frame", caption="Set wait duration for waypoint " .. #waypoint_info.waypoints, direction="vertical"}


          local length_select_frame = frame.add{type="frame", style="item_and_count_select_background", direction="horizontal"}
          gui_elements.slider = length_select_frame.add{type="slider",
                                   name="waypoints-condition-selector-slider",
                                   minimum_value=0,
                                   maximum_value=#slider_values,
                                   value=slider_value_index(tonumber(last_wait_time)),
                                   value_step=1,
                                   discrete_slider=true,
                                   style="notched_slider"
                                  }
          gui_elements.text = length_select_frame.add{type="textfield", name="waypoints-condition-selector-text", numeric=true, allow_decimal=false, allow_negative=false, lose_focus_on_confirm=true, text=last_wait_time, style="slider_value_textfield"}
          length_select_frame.add{type="label", caption="seconds"}
          gui_elements.confirm = length_select_frame.add{type="sprite-button", name="waypoints-condition-selector-confirm", mouse_button_filter={"left"}, sprite="utility/check_mark", style="item_and_count_select_confirm"}
          gui_elements.frame = frame

          gui_elements.waypoint = waypoint_info.waypoints[#waypoint_info.waypoints]
          gui_elements.spidertron = waypoint_info.spidertron
          global.selection_gui[player.index] = gui_elements

          player.opened = frame
        end
      end
    end
  end
)


-- Slider moved
script.on_event(defines.events.on_gui_value_changed,
  function(event)
    local gui_elements = global.selection_gui[event.player_index]
    if gui_elements and event.element == gui_elements.slider then
      gui_elements.text.text = slider_values[gui_elements.slider.slider_value]
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

local function save_and_exit_gui(player, gui_elements)
  local wait_time = gui_elements.text.text
  gui_elements.frame.destroy()
  global.selection_gui[player.index] = nil

  -- Set last waypoint's wait time to wait_time
  local waypoint = gui_elements.waypoint
  log("Wait time set to " .. wait_time .. " at position " .. util.positiontostr(waypoint.position))
  waypoint.wait_time = tonumber(wait_time)
  global.last_wait_times[player.index] = wait_time
  if gui_elements.spidertron then  -- if condition for guis created in 1.4.3
    update_text(gui_elements.spidertron)
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
script.on_event("waypoints-gui-confirm",
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
