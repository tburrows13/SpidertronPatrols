local gui = require "__SpidertronPatrols__.scripts.gui-beta"
local PatrolGui = require "scripts.patrol-gui"
local DockGui = require "scripts.dock-gui"

gui.hook_events(function(event)
  if event.name == defines.events.on_gui_opened then
    PatrolGui.on_gui_opened(event)
    DockGui.on_gui_opened(event)
  elseif event.name == defines.events.on_gui_closed then
    PatrolGui.on_gui_closed(event)
    DockGui.on_gui_closed(event)
  end

  local msg = gui.read_action(event)
  if msg then
    if msg.gui == "patrol" then
      PatrolGui.handle_action(msg, event)
    elseif msg.gui == "dock" then
      DockGui.handle_action(msg, event)
    end
  end
end)