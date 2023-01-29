local gui = require "__SpidertronPatrols__.scripts.gui-lite"

PatrolGui = {}
local PatrolGuiWaypoint = {}

dropdown_contents = {
  {"description.no-limit"},
  {"gui-train.add-time-condition"},
  {"gui-train.add-inactivity-condition"},
  {"gui-patrol.full-inventory-condition"},
  {"gui-patrol.empty-inventory-condition"},
  {"gui-train.add-item-count-condition"},
  {"gui-train.add-circuit-condition"},
  {"gui-train.add-robots-inactive-condition"},
  {"gui-patrol.driver-present"},
  {"gui-patrol.driver-not-present"},
}

dropdown_index = {
  ["none"] = 1,
  ["time-passed"] = 2,
  ["inactivity"] = 3,
  ["full-inventory"] = 4,
  ["empty-inventory"] = 5,
  ["item-count"] = 6,
  ["circuit-condition"] = 7,
  ["robots-inactive"] = 8,
  ["passenger-present"] = 9,
  ["passenger-not-present"] = 10,
}

dropdown_index_lookup = {
  "none",
  "time-passed",
  "inactivity",
  "full-inventory",
  "empty-inventory",
  "item-count",
  "circuit-condition",
  "robots-inactive",
  "passenger-present",
  "passenger-not-present",
}


condition_dropdown_contents = {">", "<", "=", "≥", "≤", "≠"}


local slider_values = {5, 10, 30, 60, 120, 600}
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


local function build_waypoint_player_input(i, waypoint)
  local waypoint_type = waypoint.type
  if waypoint_type == "time-passed" or waypoint_type == "inactivity" then
    return {
      {
        type = "slider", style = "sp_compact_notched_slider", minimum_value = 0, maximum_value = #slider_values, value = slider_value_index(waypoint.wait_time), discrete_slider = true,
        ref = {"time_slider", i},
        handler = {[defines.events.on_gui_value_changed] = PatrolGuiWaypoint.update_text_field}, tags = {index = i},
      },
      {
        type = "textfield", style = "sp_compact_slider_value_textfield", text = tostring(waypoint.wait_time) .. " s",  numeric = true, allow_decimal = false, allow_negative = false, lose_focus_on_confirm = true,
        ref = {"time_textfield", i},
        handler = {
          [defines.events.on_gui_text_changed] = PatrolGuiWaypoint.update_slider,
          [defines.events.on_gui_click] = PatrolGuiWaypoint.remove_s,
          [defines.events.on_gui_confirmed] = PatrolGuiWaypoint.add_s,
        },
        tags = {index = i},
      }
    }
  elseif waypoint_type == "item-count" or waypoint_type == "circuit-condition" then
    local info = waypoint.item_count_info
    local elem_type = waypoint_type == "item-count" and "item" or "signal"
    return {
      {
        type = "choose-elem-button", style = "train_schedule_item_select_button", elem_type = elem_type, item = info.item_name, signal = info.item_name,
        handler = {[defines.events.on_gui_elem_changed] = PatrolGuiWaypoint.item_selected}, tags = {index = i},
      },
      {
        type = "drop-down", style = "circuit_condition_comparator_dropdown", items = condition_dropdown_contents, selected_index = info.condition,
        handler = {[defines.events.on_gui_selection_state_changed] = PatrolGuiWaypoint.item_condition_changed}, tags = {index = i},
      },
      {
        type = "textfield", style = "sp_compact_slider_value_textfield", text = tostring(info.count), numeric = true, allow_decimal = false, allow_negative = waypoint_type == "circuit-condition", lose_focus_on_confirm = true,
        handler = {[defines.events.on_gui_text_changed] = PatrolGuiWaypoint.item_count_changed}, tags = {index = i},
      },
    }
  end
end

local function generate_button_status(waypoint_info, index)
  local style = "train_schedule_action_button"
  local sprite = "utility/play"
  if waypoint_info.on_patrol and waypoint_info.current_index == index then
    style = "sp_clicked_train_schedule_action_button"
    if waypoint_info.tick_arrived then
      sprite = "utility/stop"
    end
  end
  return {style = style, sprite = sprite}
end

local function build_waypoint_frames(waypoint_info)
  --waypoint_info.waypoints = {{type = "none"}, {type = "time-passed", wait_time = 5}, {type = "inactivity", wait_time = 10}}--{type = "full-inventory"}, {type = "empty-inventory"}, {type = "robots-inactive"}, {type = "passenger-present"}, {type = "passenger-not-present"}, {type = "none"}, {type = "time-passed", wait_time = 5}, {type = "inactivity", wait_time = 10}, {type = "full-inventory"}, {type = "empty-inventory"}, {type = "robots-inactive"}, {type = "passenger-present"}, {type = "passenger-not-present"}, {type = "none"}, {type = "time-passed", wait_time = 5}, {type = "inactivity", wait_time = 10}, {type = "full-inventory"}, {type = "empty-inventory"}, {type = "robots-inactive"}, {type = "passenger-present"}, {type = "passenger-not-present"}}
  local frames = {}
  for i, waypoint in pairs(waypoint_info.waypoints) do
    local button_status = generate_button_status(waypoint_info, i)
    table.insert(frames,
      {type = "frame", --[[name = "schedule-waypoint-" .. i,]] style = "sp_spidertron_schedule_station_frame", children = {
        {
          type = "sprite-button", name = "status_button", style = button_status.style, mouse_button_filter = {"left"}, sprite = button_status.sprite,
          handler = {[defines.events.on_gui_click] = PatrolGuiWaypoint.go_to_waypoint}, tags = {index = i},
        },
        {
          type = "label", style = "sp_spidertron_waypoint_label", caption = "#" .. tostring(i),
          handler = {[defines.events.on_gui_click] = PatrolGuiWaypoint.move_camera_to_waypoint}, tags = {index = i},
        },
        {
          type = "drop-down", items = dropdown_contents, selected_index = dropdown_index[waypoint.type],
          ref = {"waypoint_dropdown", i},
          tooltip = waypoint.type == "circuit-condition" and {"gui-patrol.circuit-condition-tooltip"} or nil,
          handler = {[defines.events.on_gui_selection_state_changed] = PatrolGuiWaypoint.waypoint_type_changed}, tags = {index = i},
        },
        {
          type = "flow", style = "sp_player_input_horizontal_flow", children =
          build_waypoint_player_input(i, waypoint)
        },
        {type = "empty-widget", style = "sp_empty_filler"},
        {
          type = "sprite-button", name = "up", style = "sp_schedule_move_button", mouse_button_filter = {"left"}, sprite = "sp-up-white", hovered_sprite = "sp-up-black", clicked_sprite = "sp-up-black",
          ref = {"waypoint_button", i, "up"},
          handler = {[defines.events.on_gui_click] = PatrolGuiWaypoint.move_waypoint_up}, tags = {index = i},
        },
        {
          type = "sprite-button", name = "down", style = "sp_schedule_move_button", mouse_button_filter = {"left"}, sprite = "sp-down-white", hovered_sprite = "sp-down-black", clicked_sprite = "sp-down-black",
          ref = {"waypoint_button", i, "down"},
          handler = {[defines.events.on_gui_click] = PatrolGuiWaypoint.move_waypoint_down}, tags = {index = i},
        },
        {
          type = "sprite-button", style = "train_schedule_delete_button", mouse_button_filter = {"left"}, sprite = "utility/close_white", hovered_sprite = "utility/close_black", clicked_sprite = "utility/close_black",
          handler = {[defines.events.on_gui_click] = PatrolGuiWaypoint.delete_waypoint}, tags = {index = i},
        },
      }}
    )
  end
    -- 'Add new waypoint' button
    table.insert(frames,
    {
      type = "button",
      style = "sp_spidertron_schedule_add_station_button",
      mouse_button_filter = {"left"},
      caption = {"gui-patrol.add-waypoint"},
      --tooltip = {"gui-patrol.add-waypoint-tooltip"},
      tooltip = game.item_prototypes["sp-spidertron-patrol-remote"].localised_description,
      handler = {[defines.events.on_gui_click] = PatrolGui.give_connected_remote},
    })
  return frames
end

local function build_on_patrol_switch(waypoint_info)
  local switch_state
  if waypoint_info.on_patrol then switch_state = "left" else switch_state = "right" end
  return {
    type = "switch",
    name = "on_patrol_switch",
    handler = {[defines.events.on_gui_switch_state_changed] = PatrolGui.toggle_on_patrol},
    switch_state = switch_state,
    left_label_caption = {"gui-train.automatic-mode"},
    right_label_caption = {"gui-train.manual-mode"}}
end


local function build_gui(player, spidertron)
  local waypoint_info = get_waypoint_info(spidertron)
  local anchor = {gui = defines.relative_gui_type.spider_vehicle_gui, position = defines.relative_gui_position.right}
  if not next(waypoint_info.waypoints) then return end

  -- Avoid by setting (configurable) max height https://forums.factorio.com/viewtopic.php?f=7&t=98151
  local maximal_height = 930
  if script.active_mods["AutoTrash"] then maximal_height = 650 end
  maximal_height = maximal_height * player.mod_settings["sp-window-height-scale"].value
  return gui.add(player.gui.relative, {
    {
      type = "frame",
      style = "sp_relative_stretchable_frame",
      name = "sp-relative-frame",
      direction = "vertical",
      anchor = anchor,
      style_mods = {maximal_height = maximal_height},
      children = {
          {type = "label", style = "frame_title", caption = {"gui-train.schedule"}, ignored_by_interaction = true},
        {type = "flow", direction = "vertical", style = "inset_frame_container_vertical_flow", children = {
          {type = "frame", style = "inside_shallow_frame", children = {
            {
              type = "camera", style = "sp_spidertron_camera", position = spidertron.position, surface_index = spidertron.surface.index, zoom = 0.75,
              elem_mods = {entity = spidertron},
              name = "camera",
            },
          }},
          {type = "frame", direction = "vertical", style = "inside_shallow_frame", children = {
            {type = "frame", direction = "horizontal", style = "sp_stretchable_subheader_frame", children = {
              {type = "flow", style = "sp_patrol_schedule_mode_switch_horizontal_flow", children = {
                build_on_patrol_switch(waypoint_info),
                {type = "empty-widget", style = "sp_stretchable_empty_widget"},
                {
                  type = "sprite-button", style = "sp_clicked_tool_button", mouse_button_filter = {"left"}, sprite = "sp-camera", tooltip = {"gui-patrol.toggle-camera"},
                  name = "toggle_camera_button",
                  handler = {[defines.events.on_gui_click] = PatrolGui.toggle_camera},
                },
                {
                  type = "sprite-button", style = "sp_clicked_tool_button", mouse_button_filter = {"left"}, sprite = "utility/center", tooltip = {"gui-patrol.toggle-center-on-spidertron"},
                  name = "toggle_center_button",
                  handler = {[defines.events.on_gui_click] = PatrolGui.toggle_camera_center_on_spidertron},
                },
                {
                  type = "sprite-button", style = "tool_button", mouse_button_filter = {"left"}, sprite = "utility/map", tooltip = {"gui-train.open-in-map"},
                  handler = {[defines.events.on_gui_click] = PatrolGui.open_location_on_map},
                },
                {
                  type = "sprite-button", style = "tool_button_red", mouse_button_filter = {"left"}, sprite = "utility/reset", tooltip = {"gui-patrol.delete-all-waypoints"},
                  handler = {[defines.events.on_gui_click] = PatrolGui.delete_all_waypoints},
                },
              }},
            }},
            {type = "scroll-pane", style = "sp_spidertron_schedule_scroll_pane", name = "schedule-scroll-pane", horizontal_scroll_policy = "never", vertical_scroll_policy = "auto-and-reserve-space", children =
              build_waypoint_frames(waypoint_info)
            }
          }},
        }},
      }
    }
  })
end

function PatrolGui.update_gui_button_states(waypoint_info)
  -- Lightweight version of PatrolGui.update_gui_schedule that only touches the play/stop buttons
  -- Use when not the result of a GUI interaction
  for _, player in pairs(game.players) do
    if player.opened_gui_type == defines.gui_type.entity and player.opened == waypoint_info.spidertron then
      local gui_elements = global.open_gui_elements[player.index]
      if gui_elements then
        local scroll_pane = gui_elements["schedule-scroll-pane"]
        for i, frame in pairs(scroll_pane.children) do
          local status_button = frame.status_button
          if status_button then
            -- Filters out "Add waypoints" button
            local button_status = generate_button_status(waypoint_info, i)
            status_button.style = button_status.style
            status_button.sprite = button_status.sprite
          end
        end
      end
    end
  end
end

function PatrolGui.update_gui_schedule(waypoint_info)
  local spidertron = waypoint_info.spidertron

  for _, player in pairs(game.players) do
    if player.opened_gui_type == defines.gui_type.entity and player.opened == waypoint_info.spidertron then
      local gui_elements = global.open_gui_elements[player.index]
      if gui_elements then
        local scroll_pane = gui_elements["schedule-scroll-pane"]
        scroll_pane.clear()
        local waypoint_frames = build_waypoint_frames(waypoint_info)
        if next(waypoint_frames) then
          local new_gui_elements = gui.add(scroll_pane, waypoint_frames)
          -- Copy across new gui elements to global storage
          gui_elements.waypoint_dropdown = new_gui_elements.waypoint_dropdown
          gui_elements.time_slider = new_gui_elements.time_slider
          gui_elements.time_textfield = new_gui_elements.time_textfield
          gui_elements.waypoint_button = new_gui_elements.waypoint_button
        else
          -- Clear GUI
          local relative_frame = player.gui.relative["sp-relative-frame"]
          if relative_frame then
            relative_frame.destroy()
          end
          global.open_gui_elements[player.index] = nil
        end
      else
        global.open_gui_elements[player.index] = build_gui(player, spidertron)
      end
    end
  end
end

function PatrolGui.update_gui_switch(waypoint_info)
  for _, player in pairs(game.players) do
    if player.opened_gui_type == defines.gui_type.entity and player.opened == waypoint_info.spidertron then
      local gui_elements = global.open_gui_elements[player.index]
      if gui_elements then
        gui_elements.on_patrol_switch.switch_state = build_on_patrol_switch(waypoint_info).switch_state
        PatrolGui.update_gui_button_states(waypoint_info)
      end
    end
  end
end

function PatrolGui.update_gui_highlights()
  -- Called every tick
  for player_index, button_info in pairs(global.player_highlights) do
    local button = button_info.button
    local tick_started = button_info.tick_started
    if button and button.valid then
      if (game.tick - tick_started) > 20 then
        button.style = "sp_schedule_move_button"
        button.sprite = "sp-" .. button.name .. "-white"
        global.player_highlights[player_index] = nil
      end
    else
      global.player_highlights[player_index] = nil
    end
  end
end


function PatrolGui.clear_highlights_for_player(player)
  local button_info = global.player_highlights[player.index]
  if button_info then
    local button = button_info.button
    if button and button.valid then
      button.style = "sp_schedule_move_button"
      button.sprite = "sp-" .. button.name .. "-white"
    end
    global.player_highlights[player.index] = nil
  end
end

script.on_event(defines.events.on_gui_opened,
  function(event)
    local player = game.get_player(event.player_index)
    local entity = event.entity
    if entity and entity.type == "spider-vehicle" then
      update_player_render_paths(player)

      local relative_frame = player.gui.relative["sp-relative-frame"]
      if relative_frame then
        relative_frame.destroy()
      end
      global.open_gui_elements[player.index] = build_gui(player, entity)
    end
  end
)

script.on_event(defines.events.on_gui_closed,
  function(event)
    local player = game.get_player(event.player_index)
    local entity = event.entity
    if entity and entity.type == "spider-vehicle" then
      local relative_frame = player.gui.relative["sp-relative-frame"]
      if relative_frame then
        relative_frame.destroy()
      end
      global.open_gui_elements[player.index] = nil

      -- Spidertron's color could have changed
      update_render_text(entity)
    end
  end
)

function PatrolGui.toggle_camera(player, spidertron, gui_elements)
  local camera_button = gui_elements.toggle_camera_button
  local camera = gui_elements.camera
  if camera_button.style.name == "tool_button" then
    -- Button was clicked
    camera_button.style = "sp_clicked_tool_button"
    camera.parent.visible = true
  else
    -- Button was unclicked
    camera_button.style = "tool_button"
    camera.parent.visible = false
  end
end

function PatrolGui.toggle_camera_center_on_spidertron(player, spidertron, gui_elements)
  local center_button = gui_elements.toggle_center_button
  local camera = gui_elements.camera
  if center_button.style.name == "tool_button" then
    -- Button was clicked
    center_button.style = "sp_clicked_tool_button"
    camera.entity = spidertron
  else
    -- Button was unclicked
    center_button.style = "tool_button"
    camera.entity = nil
    camera.position = spidertron.position
  end
end

function PatrolGui.open_location_on_map(player, spidertron, gui_elements)
  local camera = gui_elements.camera
  local entity = camera.entity
  if entity then
    -- At 100% interface scale (display_scale=1), 1/16 is identical to vanilla 'open in map' scale
    -- At 200% interface scale (display_scale=2), 1/8
    if global.base_version[2] > 1 or global.base_version[3] >= 75 then
      -- base >= 1.1.75
      player.open_map(entity.position, (1/16) * player.display_scale, entity)  
    else
      player.open_map(entity.position, (1/16) * player.display_scale)
    end
  else
    player.open_map(camera.position, (1/16) * player.display_scale)
  end
  player.opened = nil
end

function PatrolGui.delete_all_waypoints(player, spidertron, gui_elements)
  clear_spidertron_waypoints(spidertron)
end

function set_on_patrol(on_patrol, spidertron, waypoint_info)
  if on_patrol then
    SpidertronControl.go_to_next_waypoint(spidertron, waypoint_info.current_index)
  else
    spidertron.autopilot_destination = nil
  end
  waypoint_info.on_patrol = on_patrol
  PatrolGui.update_gui_switch(waypoint_info)
end

function PatrolGui.toggle_on_patrol(player, spidertron, gui_elements)
  local switch = gui_elements.on_patrol_switch
  local waypoint_info = global.spidertron_waypoints[spidertron.unit_number]
  local on_patrol = switch.switch_state == "left"
  set_on_patrol(on_patrol, spidertron, waypoint_info)
end

function PatrolGui.give_connected_remote(player, spidertron, gui_elements)
  if not player.is_cursor_empty() then
    local cleared = player.clear_cursor()
    if not cleared then return end
  end
  local cursor = player.cursor_stack
  cursor.set_stack("sp-spidertron-patrol-remote")
  cursor.connected_entity = spidertron
end

function PatrolGuiWaypoint.go_to_waypoint(player, spidertron, gui_elements, waypoint_info, index)
  -- 'Play' button
  if not waypoint_info.on_patrol or index ~= waypoint_info.current_index then
    set_on_patrol(true, spidertron, waypoint_info)
    SpidertronControl.go_to_next_waypoint(spidertron, index)
  end
end

function PatrolGuiWaypoint.move_camera_to_waypoint(player, spidertron, gui_elements, waypoint_info, index)
  -- Numbered labels
  local center_button = gui_elements.toggle_center_button
  local camera = gui_elements.camera

  center_button.style = "tool_button"
  camera.entity = nil
  camera.position = waypoint_info.waypoints[index].position
end

function PatrolGuiWaypoint.waypoint_type_changed(player, spidertron, gui_elements, waypoint_info, index, element)
  local dropdown = gui_elements.waypoint_dropdown[index]
  local waypoint = waypoint_info.waypoints[index]
  local new_waypoint_type = dropdown_index_lookup[dropdown.selected_index]
  if waypoint.type ~= new_waypoint_type then
    waypoint.type = new_waypoint_type
    element.tooltip = nil
    if new_waypoint_type == "time-passed" then
      waypoint.wait_time = 30
    elseif new_waypoint_type == "inactivity" then
      waypoint.wait_time = 5
    else
      waypoint.wait_time = nil
    end
    if new_waypoint_type == "item-count" then
      waypoint.item_count_info = {item_name = nil, condition = 4, count = 100}
    elseif new_waypoint_type == "circuit-condition" then
      waypoint.item_count_info = {item_name = nil, condition = 1, count = 0}
      element.tooltip = {"gui-patrol.circuit-condition-tooltip"}
    else
      waypoint.item_count_info = nil
    end
    PatrolGui.update_gui_schedule(waypoint_info)
  end
end

function PatrolGuiWaypoint.move_waypoint_up(player, spidertron, gui_elements, waypoint_info, index)
  local waypoints = waypoint_info.waypoints
  local index_to_move = index
  if index_to_move ~= 1 then
    local index_above = index - 1

    --[[
    -- TODO Get shift-click working. Currently swaps top and current instead of shifting all down
    if event.shift then
      index_above = 1
    end
    ]]

    local waypoint_to_move = util.table.deepcopy(waypoints[index_to_move])
    local waypoint_above = util.table.deepcopy(waypoints[index_above])

    waypoints[index_above] = waypoint_to_move
    waypoints[index_to_move] = waypoint_above

    local current_index = waypoint_info.current_index
    if current_index then
      if current_index == index_above then waypoint_info.current_index = index_to_move end
      if current_index == index_to_move then waypoint_info.current_index = index_above end
    end

    PatrolGui.update_gui_schedule(waypoint_info)
    update_render_text(spidertron)

    local button = gui_elements.waypoint_button[index_above].up
    button.style = "sp_selected_schedule_move_button"
    button.sprite = "sp-up-black"

    PatrolGui.clear_highlights_for_player(player)
    global.player_highlights[player.index] = {button = button, tick_started = game.tick}
  end
end

function PatrolGuiWaypoint.move_waypoint_down(player, spidertron, gui_elements, waypoint_info, index)
  local waypoints = waypoint_info.waypoints
  local index_to_move = index
  if index_to_move ~= #waypoints then
    local index_below = index + 1

    --[[
    if event.shift then
      index_below = #waypoints
    end
    ]]

    local waypoint_to_move = util.table.deepcopy(waypoints[index_to_move])
    local waypoint_below = util.table.deepcopy(waypoints[index_below])

    waypoints[index_below] = waypoint_to_move
    waypoints[index_to_move] = waypoint_below

    local current_index = waypoint_info.current_index
    if current_index then
      if current_index == index_below then waypoint_info.current_index = index_to_move end
      if current_index == index_to_move then waypoint_info.current_index = index_below end
    end

    PatrolGui.update_gui_schedule(waypoint_info)
    update_render_text(spidertron)

    local button = gui_elements.waypoint_button[index_below].down
    button.style = "sp_selected_schedule_move_button"
    button.sprite = "sp-down-black"

    PatrolGui.clear_highlights_for_player(player)
    global.player_highlights[player.index] = {button = button, tick_started = game.tick}
  end
end

function PatrolGuiWaypoint.delete_waypoint(player, spidertron, gui_elements, waypoint_info, index)
  local waypoints = waypoint_info.waypoints
  local index_to_delete = index
  if waypoint_info.current_index > index_to_delete then
    waypoint_info.current_index = waypoint_info.current_index - 1
  end
  rendering.destroy(waypoints[index_to_delete].render_id)
  table.remove(waypoints, index_to_delete)
  if not next(waypoints) then
    -- All waypoints are gone, so cleanup
    clear_spidertron_waypoints(spidertron)
  end
  if not waypoints[index_to_delete] then
    waypoint_info.current_index = 1
  end
  if waypoint_info.on_patrol then
    SpidertronControl.go_to_next_waypoint(spidertron, waypoint_info.current_index)
  end
  PatrolGui.update_gui_schedule(waypoint_info)
  update_render_text(spidertron)
end

local function set_waypoint_time(wait_time, spidertron, waypoint_index)
  local waypoint_info = get_waypoint_info(spidertron)
  local waypoint = waypoint_info.waypoints[waypoint_index]
  waypoint.wait_time = wait_time
end

function PatrolGuiWaypoint.update_text_field(player, spidertron, gui_elements, waypoint_info, index)
  local wait_time = slider_values[gui_elements.time_slider[index].slider_value]
  gui_elements.time_textfield[index].text = tostring(wait_time) .. " s"

  set_waypoint_time(wait_time, player.opened, index)
end

function PatrolGuiWaypoint.update_slider(player, spidertron, gui_elements, waypoint_info, index)
  local text = gui_elements.time_textfield[index].text
  if text == "" then text = "0" end
  local wait_time = tonumber(text)
  gui_elements.time_slider[index].slider_value = slider_value_index(wait_time)

  set_waypoint_time(wait_time, player.opened, index)
end

function PatrolGuiWaypoint.remove_s(player, spidertron, gui_elements, waypoint_info, index)
  local textfield = gui_elements.time_textfield[index]
  local current_text = textfield.text
  if current_text:sub(-2, -1) == " s" then
    textfield.text = textfield.text:sub(0, -3)
  end
end

function PatrolGuiWaypoint.add_s(player, spidertron, gui_elements, waypoint_info, index)
  local textfield = gui_elements.time_textfield[index]
  textfield.text = textfield.text .. " s"
end

function PatrolGuiWaypoint.item_selected(player, spidertron, gui_elements, waypoint_info, index, element)
  local elem_button = element
  local item_count_info = waypoint_info.waypoints[index].item_count_info
  item_count_info.item_name = elem_button.elem_value
end

function PatrolGuiWaypoint.item_condition_changed(player, spidertron, gui_elements, waypoint_info, index, element)
  local dropdown = element
  local item_count_info = waypoint_info.waypoints[index].item_count_info
  item_count_info.condition = dropdown.selected_index
end

function PatrolGuiWaypoint.item_count_changed(player, spidertron, gui_elements, waypoint_info, index, element)
  local item_count_info = waypoint_info.waypoints[index].item_count_info
  local text = element.text
  if text == "" then text = "0" end
  local item_count = tonumber(text)
  item_count_info.count = item_count
end

gui.add_handlers(PatrolGui,
  function(event, handler)
    local player = game.get_player(event.player_index)
    local spidertron = player.opened
    local gui_elements = global.open_gui_elements[player.index]
    if gui_elements then
      handler(player, spidertron, gui_elements)
    end
  end
)

gui.add_handlers(PatrolGuiWaypoint,
  function(event, handler)
    local player = game.get_player(event.player_index)
    local spidertron = player.opened
    local gui_elements = global.open_gui_elements[player.index]
    if gui_elements then
      local waypoint_info = global.spidertron_waypoints[spidertron.unit_number]
      local index = event.element.tags.index
      -- TODO look at using event.element in all events or none
      handler(player, spidertron, gui_elements, waypoint_info, index, event.element)
    end
  end
)

gui.handle_events()

return PatrolGui