-- Unused
time_select_gui = {}

function time_select_gui.build_gui(initial_time, unit_number, index)
  return {
    {type = "frame", caption = "Select time", ref = {"frame"}, tags = {unit_number = unit_number, index = index}, children = {
      {type = "frame", style = "item_and_count_select_background", children = {
        {type = "flow", style = "player_input_horizontal_flow", children = {
          {
            type = "slider", minimum_value = 0, maximum_value = 120, value = initial_time,
            ref = {"slider"},
            actions = {on_value_changed = {gui = "time_select", action = "update_text_field"}}
          },
          {
            type = "textfield", style = "slider_value_textfield", numeric = true, allow_decimal = false, allow_negative = false, text = tostring(initial_time), lose_focus_on_confirm = true,
            ref = {"textfield"},
            actions = {on_text_changed = {gui = "time_select", action = "update_slider"}}
          }
        }},
        {
          type = "sprite-button", style = "item_and_count_select_confirm", mouse_button_filter = {"left"}, sprite="utility/check_mark",
          ref = {"confirm"},
          actions = {on_click = {gui = "time_select", action = "confirm"}}
        }
      }}
    }}
  }
end

-- Slider moved
function time_select_gui.on_gui_value_changed(gui_elements)
  gui_elements.textfield.text = tostring(gui_elements.slider.slider_value)
end

-- Text box confirmed (not the whole gui)
function time_select_gui.on_gui_text_changed(gui_elements)
  local text = gui_elements.textfield.text
  if text == "" then
    text = "0"
  end
  value = tonumber(text)
  gui_elements.slider.slider_value = value
end

local function save_and_exit_gui(gui_elements, waypoint_info)
  local wait_time = gui_elements.textfield.text

  local waypoint = waypoint_info.waypoints[gui_elements.frame.tags["SpidertronWaypoints"].index]
  waypoint.wait_time = wait_time

  gui_elements.frame.destroy()

  patrol_gui.update_gui_schedule(waypoint_info)
end

function time_select_gui.on_gui_click(gui_elements, waypoint_info)
  save_and_exit_gui(gui_elements, waypoint_info)
end

script.on_event("sp-confirm-gui",  -- Called when the player presses 'E'
function(event)
  local player = game.get_player(event.player_index)
  local gui_elements = global.open_gui_elements[event.player_index]
  if gui_elements then
    local time_select = gui_elements.time_select
    if time_select and time_select.frame and time_select.frame.valid then
      local waypoint_info = global.spidertron_waypoints[time_select.frame.tags["SpidertronWaypoints"].unit_number]
      save_and_exit_gui(time_select, waypoint_info)
    end
  end
end
)


return time_select_gui