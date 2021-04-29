--[[local hard_shadow_color = {0, 0, 0, 1}
local function default_inner_glow(tint_value, scale_value)
  return
  {
    position = {183, 128},
    corner_size = 8,
    tint = tint_value,
    scale = scale_value,
    draw_type = "inner"
  }
end
local default_inner_shadow = default_inner_glow(hard_shadow_color, 0.5)]]

local styles = data.raw["gui-style"]["default"]

-- Doesn't seem to work
styles.sp_relative_stretchable_frame = {
  type = "frame_style",
  vertically_stretchable = "stretch_and_expand",
}

-- Doesn't seem to work
styles.sp_spidertron_schedule_scroll_pane = {
  type = "scroll_pane_style",
  parent = "train_schedule_scroll_pane",
  vertically_stretchable = "stretch_and_expand",
  background_graphical_set = {
    position = {282, 17},
    corner_size = 8,
    custom_horizontal_tiling_sizes = {28, 440},
    overall_tiling_horizontal_spacing = 8,
    overall_tiling_horizontal_padding = 4,
    overall_tiling_vertical_spacing = 12,
    overall_tiling_vertical_size = 28,
    overall_tiling_vertical_padding = 4
  }
}

styles.waypoints_switch_padding = {type = "switch_style", parent = "switch", top_padding = 3}  -- Fixes height of switch to be the same as its labels
styles.waypoints_empty_filler = {type = "empty_widget_style", horizontally_stretchable = "on"}
styles.stretchable_subheader_frame = {
  type = "frame_style",
  parent = "frame",
  horizontally_stretchable = "on",
}

styles.sp_spidertron_schedule_station_frame = {
  type = "frame_style",
  parent = "train_schedule_station_frame",
  width = 480,
}


--local train_schedule_action_button = styles.train_schedule_action_button
local button_style = styles["button"]
styles.sp_clicked_train_schedule_action_button = {
  type = "button_style",
  parent = "train_schedule_action_button",
  default_graphical_set = button_style.clicked_graphical_set,
  --clicked_graphical_set = button_style.default_graphical_set  -- TODO Make this behave more like train button
}
styles.sp_clicked_tool_button = {
  type = "button_style",
  parent = "tool_button",
  default_graphical_set = button_style.clicked_graphical_set,
}

styles.sp_spidertron_camera = {
  type = "camera_style",
  minimal_height = 256,
  minimal_width = 256,
  horizontally_stretchable = "on",
  graphical_set = {}
}
styles.sp_spidertron_minimap_frame = {
  type = "frame_style",
  padding = 0,
  margin = 4,
  graphical_set =
  {
    base = {position = {17, 0}, corner_size = 8, draw_type = "outer"},
    shadow = default_inner_shadow
  },
  --size = 240
}
styles.sp_spidertron_waypoint_label = {
  type = "label_style",
  parent = "clickable_label",
  font = "default-bold",
  left_padding = 4,
  minimal_width = 32
}




styles.sp_stretchable_empty_widget = {
  type = "empty_widget_style",
  horizontally_stretchable = "stretch_and_expand",
  horizontally_squashable = "on",
}
