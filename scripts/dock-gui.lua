local gui = require "__SpidertronPatrols__.scripts.gui-beta"

local DockGui = {}

local function build_gui(player, dock_data)
  local anchor = {gui = defines.relative_gui_type.container_gui, position = defines.relative_gui_position.right}

  -- Avoid by setting (configurable) max height https://forums.factorio.com/viewtopic.php?f=7&t=98151
  local maximal_height = 930
  maximal_height = maximal_height * player.mod_settings["sp-window-height-scale"].value
  return gui.build(player.gui.relative, {
    {
      type = "frame",
      style = "sp_relative_stretchable_frame",
      name = "sp-relative-frame",
      direction = "vertical",
      anchor = anchor,
      style_mods = {maximal_height = maximal_height, width = 300},
      children = {
        {type = "flow", ref = {"titlebar", "flow"}, children = {
          {type = "label", style = "frame_title", caption = "Name", ignored_by_interaction = true},
          {type = "empty-widget", style = "sp_titlebar_drag_handle", ignored_by_interaction = true},
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
          {type = "frame", style = "inside_shallow_frame_with_padding", children = {
            {
              type = "textfield",
              style = "textbox",
              ref = {"name_entry"},
              text = dock_data.name,
              actions = {on_confirmed = {gui = "dock", action = "rename_dock"}},
            }
          }},
        }},
      }
    }
  })
end


function DockGui.on_gui_opened(event)
  local player = game.get_player(event.player_index)
  local entity = event.entity
  if entity and (entity.type == "container" or entity.type == "logistic-container") then
    local relative_frame = player.gui.relative["sp-relative-frame"]
    if relative_frame then
      relative_frame.destroy()
    end
    local dock_data = global.spidertron_docks[entity.unit_number]
    if dock_data then
      global.open_gui_elements[player.index] = build_gui(player, dock_data)
    end
  end
end


function DockGui.on_gui_closed(event)
  local player = game.get_player(event.player_index)
  local entity = event.entity
  if entity and (entity.type == "container" or entity.type == "logistic-container") then
    -- Save textbox value
    local dock_data = global.spidertron_docks[entity.unit_number]
    if dock_data then
      local gui_elements = global.open_gui_elements[player.index]
      local textbox = gui_elements.name_entry
      local text = textbox.text
      if text then
        dock_data.name = text
      end
    end

    local relative_frame = player.gui.relative["sp-relative-frame"]
    if relative_frame then
      relative_frame.destroy()
    end
    global.open_gui_elements[player.index] = nil
  end
end

function DockGui.handle_action(action, event)
  local player = game.get_player(event.player_index)
  local dock = player.opened
  if not dock then return end
  assert(dock.type == "container" or dock.type == "logistic-container")
  local gui_elements = global.open_gui_elements[player.index]
  local dock_data = global.spidertron_docks[dock.unit_number]

  local action_name = action.action

  if action_name == "rename_dock" then
    local textbox = gui_elements.name_entry
    local text = textbox.text
    if text then
      dock_data.name = text
    end
  end
end

return DockGui