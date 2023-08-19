local DockGui = {}

local function build_gui(player, dock_mode)
  local anchor = {gui = defines.relative_gui_type.container_gui, position = defines.relative_gui_position.right}

  return gui.add(player.gui.relative, {
    {
      type = "frame",
      --style = "sp_relative_stretchable_frame",
      name = "sp-dock-relative-frame",
      direction = "vertical",
      anchor = anchor,
      --style_mods = {width = 300},
      children = {
        {type = "label", style = "frame_title", caption = {"gui-blueprint.settings"}, ignored_by_interaction = true},
        {type = "frame", direction = "vertical", style = "inside_shallow_frame_with_padding", children = {
          {
            type = "flow",
            direction = "vertical",
            style = "inset_frame_container_vertical_flow",
            children = {
              --{type = "label", caption = "My label"},
              {type = "flow", direction = "vertical", children = {
                {
                  type = "radiobutton", name = "sp-dock-mode-trunk", caption = "Trunk", state = dock_mode == "trunk",
                  handler = {[defines.events.on_gui_checked_state_changed] = DockGui.dock_mode_changed},
                },
                {
                  type = "radiobutton", name = "sp-dock-mode-fuel", caption = "Fuel", state = dock_mode == "fuel",
                  handler = {[defines.events.on_gui_checked_state_changed] = DockGui.dock_mode_changed},
                },
                --[[{
                  type = "radiobutton", name = "ll-auto-launch-full", caption = "Auto-launch when cargo full", state = silo_data.auto_launch == "full",
                  handler = {[defines.events.on_gui_checked_state_changed] = DockGui.auto_launch_changed},
                },]]
              }},
            }
          }
        }}
      }
    }
  })
end

function DockGui.dock_mode_changed(player, element, dock, dock_data, gui_elements)
  if element.name == "sp-dock-mode-trunk" then
    dock_data.mode = "trunk"
    gui_elements["sp-dock-mode-fuel"].state = false
    --silo_gui_data["ll-auto-launch-full"].state = false
  elseif element.name == "sp-dock-mode-fuel" then
    dock_data.mode = "fuel"
    gui_elements["sp-dock-mode-trunk"].state = false
    --silo_gui_data["ll-auto-launch-full"].state = false
  --[[elseif element.name == "ll-auto-launch-full" then
    silo_data.auto_launch = "full"
    silo_gui_data["ll-auto-launch-none"].state = false
    silo_gui_data["ll-auto-launch-any"].state = false]]
  end
end

gui.add_handlers(DockGui,
  function(event, handler)
    local player = game.get_player(event.player_index)
    local entity = player.opened
    if not entity or not entity.valid then return end
    local entity_data = global.spidertron_docks[entity.unit_number]
    local gui_elements = global.spidertron_dock_guis[player.index]
    handler(player, event.element, entity, entity_data, gui_elements)
  end
)


local function update_gui(player, dock_mode)
  local gui_elements = global.spidertron_dock_guis[player.index]
  gui_elements["sp-dock-mode-trunk"].state = dock_mode == "trunk"
  gui_elements["sp-dock-mode-fuel"].state = dock_mode == "fuel"
  --gui_elements["ll-auto-launch-full"].state = silo_data.auto_launch == "full"
end

local function on_gui_opened(event)
  local entity = event.entity
  if not entity or not entity.valid then return end
  if entity.name:sub(0, 19) ~= "sp-spidertron-dock-" then return end
  local player = game.get_player(event.player_index)

  --if player.gui.relative["sp-dock-relative-frame"] then
  --  player.gui.relative["sp-dock-relative-frame"].destroy()
  --end
  local entity_data = global.spidertron_docks[entity.unit_number]

  if not player.gui.relative["sp-dock-relative-frame"] then
    global.spidertron_dock_guis[player.index] = build_gui(player, entity_data.mode)
  else
    update_gui(player, entity_data.mode)
  end
end


local function on_gui_closed(event)
  local player = game.get_player(event.player_index)
  local entity = event.entity
  if not entity or not entity.valid then return end
  if entity.name:sub(0, 19) ~= "sp-spidertron-dock-" then return end
  if entity and (entity.type == "container" or entity.type == "logistic-container") then
    local relative_frame = player.gui.relative["sp-dock-relative-frame"]
    if relative_frame then
      relative_frame.destroy()
    end
    global.spidertron_dock_guis[player.index] = nil
  end
end

DockGui.events = {
  [defines.events.on_gui_opened] = on_gui_opened,
  [defines.events.on_gui_closed] = on_gui_closed,
}

DockGui.on_init = function ()
  global.spidertron_dock_guis = {}
end

DockGui.on_configuration_changed = function(changed_data)
  global.spidertron_dock_guis = global.spidertron_dock_guis or {}

  -- TODO Add 'mode' to all global.spidertron_docks
end

return DockGui