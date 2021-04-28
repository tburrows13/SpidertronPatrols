local gui = require "__SpidertronWaypoints__.scripts.gui-beta"

patrol_gui = {}

dropdown_contents = {
  "None",
  {"gui-train.add-time-condition"},
  {"gui-train.add-inactivity-condition"},
  {"gui-train.add-full-condition"},
  {"gui-train.add-empty-condition"},
  {"gui-train.add-item-count-condition"},
  {"gui-train.add-robots-inactive-condition"},
  {"gui-train-wait-condition-description.passenger-present"},
  {"gui-train-wait-condition-description.passenger-not-present"},
}
dropdown_index = {
  ["none"] = 1,
  ["time-passed"] = 2,
  ["inactivity"] = 3,
  ["full-inventory"] = 4,
  ["empty-inventory"] = 5,
  ["item-count"] = 6,
  ["robots-inactive"] = 7,
  ["passenger-present"] = 8,
  ["passenger-not-present"] = 9,
}

local function generate_number_input()
  return {
    {type = "frame", style = "number_input_frame", children = {
      {type = "flow", style = "player_input_horizontal_flow", children = {
        {type = "slider"},
        {type = "textfield", style = "slider_value_textfield"}
      }},
      {type = "sprite-button", style= "item_and_count_select_confirm", mouse_button_filter = {"left"}, sprite="utility/check_mark",
    }
    }}
  }
end

local function build_waypoint_player_input(waypoint)
  if waypoint.type == "time-passed" then
    return {
      {type = "button", style = "train_schedule_condition_time_selection_button", caption = {"time-symbol-seconds", waypoint.wait_time}},
      {type = "label", style = "squashable_label", caption = {"gui-train.passed"}}
    }
  elseif waypoint.type == "inactivity" then
    return {
      {type = "button", style = "train_schedule_condition_time_selection_button", caption = {"time-symbol-seconds", waypoint.wait_time}},
      {type = "label", style = "squashable_label", caption = {"gui-train.of-inactivity"}}
    }
  --[[elseif waypoint.type == "full-inventory" then
    return {
      {type = "label", style = "squashable_label_with_left_padding", caption = {"gui-train-wait-condition-description.full-condition"}}
    }
  elseif waypoint.type == "empty-inventory" then
    return {
      {type = "label", style = "squashable_label_with_left_padding", caption = {"gui-train-wait-condition-description.empty-condition"}}
    }]]
  end
end

local function build_waypoint_frames(waypoint_info)
  --waypoint_info.waypoints = {{type = "none"}, {type = "time-passed", wait_time = 5}, {type = "inactivity", wait_time = 10}}--{type = "full-inventory"}, {type = "empty-inventory"}, {type = "robots-inactive"}, {type = "passenger-present"}, {type = "passenger-not-present"}, {type = "none"}, {type = "time-passed", wait_time = 5}, {type = "inactivity", wait_time = 10}, {type = "full-inventory"}, {type = "empty-inventory"}, {type = "robots-inactive"}, {type = "passenger-present"}, {type = "passenger-not-present"}, {type = "none"}, {type = "time-passed", wait_time = 5}, {type = "inactivity", wait_time = 10}, {type = "full-inventory"}, {type = "empty-inventory"}, {type = "robots-inactive"}, {type = "passenger-present"}, {type = "passenger-not-present"}}
  local frames = {}
  for i, waypoint in pairs(waypoint_info.waypoints) do

    -- Set button according to current state
    local button_style = "train_schedule_action_button"
    local button_sprite = "utility/play"
    if waypoint_info.on_patrol and waypoint_info.current_index + 1 == i then
      button_style = "sp_clicked_train_schedule_action_button"
      if waypoint_info.tick_arrived then
        button_sprite = "utility/stop"
      end
    end

    table.insert(frames,
      {type = "frame", name = "schedule-waypoint-" .. i, style = "sp_spidertron_schedule_station_frame", children = {
        {type = "sprite-button", style = button_style, mouse_button_filter = {"left"}, sprite = button_sprite},
        {
          type = "label", style = "sp_spidertron_waypoint_label", caption = "#" .. tostring(i),
          actions = {on_click = {action = "move_camera_to_waypoint", index = i}}
        },
        {type = "drop-down", items = dropdown_contents, selected_index = dropdown_index[waypoint.type]},
        {type = "flow", style = "player_input_horizontal_flow", children =
          build_waypoint_player_input(waypoint)
        },
        {type = "empty-widget", style = "waypoints_empty_filler"},
        {type = "sprite-button", style = "train_schedule_delete_button", actions = {on_click = {action = "delete_waypoint", unit_number = waypoint_info.spidertron.unit_number, index = i}}, mouse_button_filter = {"left"}, sprite = "utility/close_white", hovered_sprite = "utility/close_black"}
      }}
    )
  end
  return frames
end

local function build_on_patrol_switch(waypoint_info)
  local switch_state
  if waypoint_info.on_patrol then switch_state = "left" else switch_state = "right" end
  return {
    type = "switch",
    ref = {"on-patrol-switch"},
    actions = {on_switch_state_changed = {action = "toggle_on_patrol", unit_number = waypoint_info.spidertron.unit_number}},
    switch_state = switch_state,
    left_label_caption = {"gui-train.automatic-mode"},
    right_label_caption = {"gui-train.manual-mode"}}
end


local function build_gui(player, spidertron)
  local waypoint_info = get_waypoint_info(spidertron)
  local anchor = {gui = defines.relative_gui_type.spider_vehicle_gui, position = defines.relative_gui_position.right}
  if not next(waypoint_info.waypoints) then return end
  return gui.build(player.gui.relative, {
    {
      type = "frame",
      style = "sp_relative_stretchable_frame",
      name = "sp-relative-frame",
      direction = "vertical",
      anchor = anchor,
      children = {
        {type = "flow", ref = {"titlebar", "flow"}, children = {
          {type = "label", style = "frame_title", caption = "Schedule", ignored_by_interaction = true},
          {type = "empty-widget", style = "flib_titlebar_drag_handle", ignored_by_interaction = true},
          --[[{
            type = "sprite-button",
            style = "frame_action_button",
            sprite = "utility/close_white",
            hovered_sprite = "utility/close_black",
            clicked_sprite = "utility/close_black",
            ref = {"titlebar", "close_button"},
            actions = {
              on_click = {gui = "demo", action = "close"}
            }
          }]]
        }},
        {type = "flow", direction = "vertical", style = "inset_frame_container_vertical_flow", children = {
          {type = "frame", style = "inside_shallow_frame", children = {
            --{type = "frame", style = "sp_spidertron_minimap_frame", children = {
              {type = "camera", style = "sp_spidertron_camera", ref = {"camera"}, position = spidertron.position, surface_index = spidertron.surface.index, zoom = 0.4, elem_mods = {entity = spidertron}},

              --{type = "minimap", style = "minimap", position = spidertron.position, surface_index = spidertron.surface.index, zoom = 2},
            --}},
          }},
          {type = "frame", direction = "vertical", style = "inside_shallow_frame", children = {
            {type = "frame", direction = "horizontal", style = "stretchable_subheader_frame", children = {
              {type = "flow", style = "train_schedule_mode_switch_horizontal_flow", children = {
                build_on_patrol_switch(waypoint_info),
                {type = "empty-widget", style = "sp_stretchable_empty_widget"},
                {
                  type = "sprite-button", style = "sp_clicked_tool_button", mouse_button_filter = {"left"}, sprite = "utility/center", tooltip = {"gui-patrol.center-on-spidertron"},
                  ref = {"center_button"},
                  actions = {on_click = {action = "toggle_camera_center_on_spidertron"}},
                }
              }},
            }},
            {type = "scroll-pane", style = "sp_spidertron_schedule_scroll_pane", ref = {"schedule-scroll-pane"}, horizontal_scroll_policy = "never", vertical_scroll_policy = "auto-and-reserve-space", children =
              build_waypoint_frames(waypoint_info)
            }
          }},
        }},
      }
    }
  })
  --frame.add{type = "label", caption = player.name}
end


function patrol_gui.update_gui_schedule(waypoint_info)
  local spidertron = waypoint_info.spidertron

  for _, player in pairs(game.players) do
    local gui_elements = global.open_gui_elements[player.index]
    if gui_elements then
      local scroll_pane = gui_elements["schedule-scroll-pane"]
      scroll_pane.clear()
      local waypoint_frames = build_waypoint_frames(waypoint_info)
      if next(waypoint_frames) then
        gui.build(scroll_pane, waypoint_frames)
      else
        -- Clear GUI
        local relative_frame = player.gui.relative["sp-relative-frame"]
        if relative_frame then
          relative_frame.destroy()
        end
        global.open_gui_elements[player.index] = nil
      end
    else
      local opened_gui = player.opened
      if opened_gui and player.opened_gui_type == defines.gui_type.entity and opened_gui.type == "spider-vehicle" then
        global.open_gui_elements[player.index] = build_gui(player, spidertron)
      end
    end
  end
end

function patrol_gui.update_gui_switch(waypoint_info)
  local spidertron = waypoint_info.spidertron

  for _, player in pairs(game.players) do
    local gui_elements = global.open_gui_elements[player.index]
    if gui_elements then
      local switch = gui_elements["on-patrol-switch"]
      gui.update(
        switch,
        {elem_mods = {switch_state = build_on_patrol_switch(waypoint_info).switch_state}}
      )
      patrol_gui.update_gui_schedule(waypoint_info)
    end
  end
end


script.on_event(defines.events.on_gui_opened,
  function(event)
    local player = game.get_player(event.player_index)
    local entity = event.entity
    if entity and entity.type == "spider-vehicle" then
      global.open_gui_elements = global.open_gui_elements or {}  -- TODO Remove
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
      global.open_gui_elements = global.open_gui_elements or {}  -- TODO Remove

      global.open_gui_elements[player.index] = nil
      --[[for _, frame in pairs(player.gui.relative.children) do
        if frame.name == "sp-relative-frame" then
          frame.destroy()
        end
      end]]
    end
  end
)

script.on_event(defines.events.on_gui_click,
  function(event)
    local action = gui.read_action(event)
    if action then
      local player = game.get_player(event.player_index)
      local spidertron = player.opened
      assert(spidertron.type == "spider-vehicle")
      log(serpent.block(action))
      local gui_elements = global.open_gui_elements[player.index]

      if action.action == "delete_waypoint" then
        local waypoint_info = global.spidertron_waypoints[spidertron.unit_number]
        table.remove(waypoint_info.waypoints, action.index)
        patrol_gui.update_gui_schedule(waypoint_info)

      elseif action.action == "toggle_camera_center_on_spidertron" then
        if gui_elements then
          local center_button = gui_elements.center_button
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
      elseif action.action == "move_camera_to_waypoint" then
        if gui_elements then
          local center_button = gui_elements.center_button
          local camera = gui_elements.camera
          local waypoint_info = global.spidertron_waypoints[spidertron.unit_number]

          center_button.style = "tool_button"
          camera.entity = nil
          camera.position = waypoint_info.waypoints[action.index].position
        end
      end
    end
  end
)

script.on_event(defines.events.on_gui_switch_state_changed,
  function(event)
    local action = gui.read_action(event)
    if action then
      local player = game.get_player(event.player_index)
      local spidertron = player.opened
      assert(spidertron.type == "spider-vehicle")
      log(serpent.block(action))
      if action.action == "toggle_on_patrol" then
        local gui_elements = global.open_gui_elements[player.index]
        if gui_elements then
          local switch = gui_elements["on-patrol-switch"]
          local waypoint_info = global.spidertron_waypoints[action.unit_number]
          local on_patrol = switch.switch_state == "left"
          if on_patrol then
            local next_waypoint = waypoint_info.waypoints[waypoint_info.current_index + 1] or waypoint_info.waypoints[1]
            if next_waypoint then
              spidertron.autopilot_destination = next_waypoint.position
            end
          else
            spidertron.autopilot_destination = nil
          end
          waypoint_info.on_patrol = on_patrol
          patrol_gui.update_gui_switch(waypoint_info)
        end
      end
    end
  end
)

return patrol_gui