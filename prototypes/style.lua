local styles = data.raw["gui-style"]["default"]

styles.sp_relative_stretchable_frame = {
  type = "frame_style",
  vertically_stretchable = "stretch_and_expand",
}

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

-- Only used in gui.lua
styles.waypoints_switch_padding = {type = "switch_style", parent = "switch", top_padding = 3}  -- Fixes height of switch to be the same as its labels

styles.sp_empty_filler = {
  type = "empty_widget_style",
  horizontally_stretchable = "stretch_and_expand"
}
styles.sp_stretchable_subheader_frame = {
  type = "frame_style",
  parent = "subheader_frame",
  horizontally_stretchable = "on",
  horizontally_squashable = "on",
}

styles.sp_patrol_schedule_mode_switch_horizontal_flow = {
  type = "horizontal_flow_style",
  parent = "train_schedule_mode_switch_horizontal_flow",
  vertical_align = "center",
}

styles.sp_spidertron_schedule_station_frame = {
  type = "frame_style",
  parent = "train_schedule_station_frame",
  width = 480,
  horizontally_stretchable = "off"
}


-- TODO Make these behave more like train GUI clicked buttons
local button_style = styles["button"]
styles.sp_clicked_train_schedule_action_button = {
  type = "button_style",
  parent = "train_schedule_action_button",
  default_graphical_set = button_style.clicked_graphical_set,
  --clicked_graphical_set = button_style.default_graphical_set
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

styles.sp_player_input_horizontal_flow = {
  type = "horizontal_flow_style",
  parent = "player_input_horizontal_flow",
  --horizontally_stretchable = "stretch_and_expand",
  horizontally_squashable = "on",
}

styles.sp_compact_notched_slider = {
  type = "slider_style",
  parent = "notched_slider",
  horizontally_squashable = "on",
  -- maximal_width = 115,
  natural_width = 300,
  minimal_width = 50,
}

styles.sp_compact_slider_value_textfield = {
  type = "textbox_style",
  parent = "slider_value_textfield",
  width = 60,
}