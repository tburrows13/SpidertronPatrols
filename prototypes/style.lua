local styles = data.raw["gui-style"]["default"]
local frame_width = 440

styles.sp_relative_stretchable_frame = {
  type = "frame_style",
  --vertically_stretchable = "off",
  --vertically_squashable = "on",
  maximal_height = 930,  -- Hardcoded to avoid https://forums.factorio.com/viewtopic.php?f=7&t=98151
}

-- Copied from flib_titlebar_drag_handle
styles.sp_titlebar_drag_handle = {
  type = "empty_widget_style",
  parent = "draggable_space",
  left_margin = 4,
  right_margin = 4,
  height = 24,
  horizontally_stretchable = "on"
}


styles.sp_spidertron_schedule_scroll_pane = {
  type = "scroll_pane_style",
  parent = "train_schedule_scroll_pane",
  vertically_stretchable = "stretch_and_expand",
  background_graphical_set = {
    position = {282, 17},
    corner_size = 8,
    custom_horizontal_tiling_sizes = {28, frame_width - 40},
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
  width = frame_width,
  horizontally_stretchable = "off"
}


-- TODO Make these behave more like train GUI clicked buttons
local button_style = styles["button"]
styles.sp_clicked_train_schedule_action_button = {
  type = "button_style",
  parent = "train_schedule_action_button",
  default_font_color = button_style.selected_font_color,
  default_graphical_set = button_style.selected_graphical_set,
  hovered_font_color = button_style.selected_hovered_font_color,
  hovered_graphical_set = button_style.selected_hovered_graphical_set,
  clicked_font_color = button_style.selected_clicked_font_color,
  clicked_graphical_set = button_style.selected_clicked_graphical_set
}
styles.sp_clicked_tool_button = {
  type = "button_style",
  parent = "tool_button",
  default_font_color = button_style.selected_font_color,
  default_graphical_set = button_style.selected_graphical_set,
  hovered_font_color = button_style.selected_hovered_font_color,
  hovered_graphical_set = button_style.selected_hovered_graphical_set,
  clicked_font_color = button_style.selected_clicked_font_color,
  clicked_graphical_set = button_style.selected_clicked_graphical_set
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
  horizontal_align = "center",
  minimal_width = 32,
  left_margin = -6,
  right_margin = -6,
}


styles.sp_stretchable_empty_widget = {
  type = "empty_widget_style",
  horizontally_stretchable = "stretch_and_expand",
  horizontally_squashable = "on",
}

styles.sp_player_input_horizontal_flow = {
  type = "horizontal_flow_style",
  parent = "player_input_horizontal_flow",
  natural_width = 300,  -- Will be squashed down
  horizontally_squashable = "on",
  --horizontally_stretchable = "stretch_and_expand",
  horizontal_spacing = 4,
  horizontal_align = "right",
  right_margin = -8,
}

styles.sp_compact_notched_slider = {
  type = "slider_style",
  parent = "notched_slider",
  horizontally_squashable = "on",
  natural_width = 300,  -- Set width very high but it will always be squashed down whilst taking up as much space as possible
  minimal_width = 20,
}

styles.sp_compact_slider_value_textfield = {
  type = "textbox_style",
  parent = "slider_value_textfield",
  width = 60,
}

styles.sp_schedule_move_button = {
  type = "button_style",
  parent = "train_schedule_delete_button",
  right_margin = -4,
  default_graphical_set = {
    base = {position = {68, 0}, corner_size = 8},
    shadow = {position = {399, 90}, corner_size = 4, draw_type = "outer"}  -- Removes black lines at right and bottom of shadow
  }
}
