local math2d = require "math2d"

---@alias ItemName string
---@alias QualityName string
---@alias InventoryContents table<ItemName, table<QualityName, number>>

---@class DockData
---@field dock LuaEntity
---@field connected_spidertron LuaEntity?
---@field open_port_sprite LuaRenderObject?

local Dock = {}

---@param event EventData.on_built_entity|EventData.on_entity_cloned
local function on_built(event)
  local entity = event.entity or event.destination
  if entity then
    if entity.type == "spider-vehicle" then
      script.register_on_object_destroyed(entity)
    elseif entity.name == "sp-spidertron-dock" then
      storage.spidertron_docks[entity.unit_number] = {dock = entity}
      script.register_on_object_destroyed(entity)
    end
  end
end
-- TODO add filter back
-- local on_built_filter = {{filter = "type", type = "proxy-container"}, {filter = "type", type = "spider-vehicle"}}

---@param event EventData.on_object_destroyed
function on_object_destroyed(event)
  local unit_number = event.useful_id
  if unit_number then
    -- Entity is a dock
    local dock_data = storage.spidertron_docks[unit_number]
    if dock_data then
      local spidertron = dock_data.connected_spidertron
      if spidertron and spidertron.valid then
        storage.spidertrons_docked[spidertron.unit_number] = nil
      end
      storage.spidertron_docks[unit_number] = nil
    end

    -- Entity is a spidertron
    local dock_unit_number = storage.spidertrons_docked[unit_number]
    if dock_unit_number then
      storage.spidertrons_docked[unit_number] = nil

      dock_data = storage.spidertron_docks[dock_unit_number]
      if dock_data then
        local dock = dock_data.dock
        if dock.valid then
          --dock.surface.create_entity{name = "flying-text", position = dock.position, text = {"flying-text.spidertron-removed"}}
          storage.spidertron_docks[dock.unit_number] = {dock = dock}
          Dock.animate_dock(dock_data, false)
        end
      end
    end
  end
end

---@param dock_data DockData
---@param opening boolean
function Dock.animate_dock(dock_data, opening)
  local frames = 32
  local speed = 0.5
  local tick = game.tick

  local dock = dock_data.dock

  if dock_data.open_port_sprite then
    dock_data.open_port_sprite.destroy()
    dock_data.open_port_sprite = nil
  end

  if opening then
    local schedule = storage.scheduled_docks_opening[tick + frames - 2] or {}
    table.insert(schedule, dock.unit_number)
    storage.scheduled_docks_opening[tick + frames - 2] = schedule
  end

  -- Draw animation
  -- frame = ((tick * speed) + offset) % frames
  animation_offset = -(tick * speed) % frames
  animation_speed = 1
  if not opening then
    animation_offset = frames - animation_offset
    animation_speed = -1
  end

  rendering.draw_animation{
    animation = "sp-spidertron-dock-port-animation",
    target = {
      entity = dock,
      offset = util.by_pixel_hr(-9, -46),
    },
    surface = dock.surface,
    time_to_live = frames,
    animation_offset = animation_offset,
    --animation_offset = (tick * (speed - speed') + offset) % #frames`
    --animation_offset = new_dock_name == "sp-spidertron-dock" and (game.tick % 8) or (8 - (game.tick % 8)),
    animation_speed = animation_speed,
    render_layer = "object",
  }
end


---@param bounding_box BoundingBox
---@param increase number
---@return BoundingBox
local function increase_bounding_box(bounding_box, increase)
  local left_top = bounding_box.left_top
  local right_bottom = bounding_box.right_bottom
  return {left_top = {x = left_top.x - increase, y = left_top.y - increase}, right_bottom = {x = right_bottom.x + increase, y = right_bottom.y + increase}}
end

---@param dock_data DockData
---@param spidertron LuaEntity
---@return boolean?
local function connect_to_spidertron(dock_data, spidertron)
  if storage.spidertrons_docked[spidertron.unit_number] or spidertron.speed >= 0.1 or spidertron.name == "companion" or spidertron.autopilot_destination then return end

  local inventory = spidertron.get_inventory(defines.inventory.spider_trunk)  ---@cast inventory -?
  local inventory_size = #inventory
  if inventory_size == 0 then return end  -- TODO check prototype instead?

  -- Don't connect to spidertrons containing toolbelt equipment, because we will not have a dock with the correct inventory size defined
  local grid = spidertron.grid
  if grid then
    -- Inventory size bonus remains the tick that the toolbelt is removed. This works, and maybe a future `grid.inventory_bonus` would work too
    if inventory_size ~= math.floor(spidertron.prototype.get_inventory_size(defines.inventory.spider_trunk) * (1 + (spidertron.quality.level * 0.3))) then
      for _, player in pairs(spidertron.force.players) do
        -- Only print warning every 2 seconds. This may fail when more than 20 docks are placed...
        if game.tick % 120 == 0 then
          if player.surface == spidertron.surface then
            player.create_local_flying_text{
              text = {"flying-text.spidertron-toolbelts-cannot-be-docked", SPIDERTRON_NAME_CAPITALISED},
              position = dock_data.dock.position,
            }
          end
        end
      end
    return
    end
  end

  -- Check if driver has prevent-docking-when-driving enabled
  local patrol_data = get_patrol_data(spidertron)
  if not patrol_data.on_patrol then  -- Only check for drivers if not in automatic mode
    local driver = spidertron.get_driver()
    if driver then
      if driver.object_name == "LuaEntity" then
        driver = driver.player
      end
      if driver then
        local player_settings = driver.mod_settings
        if player_settings["sp-prevent-docking-when-driving"] and player_settings["sp-prevent-docking-when-driving"].value then
          return
        end
      end
    end
  end

  dock_data.dock.proxy_target_entity = spidertron
  dock_data.dock.proxy_target_inventory = defines.inventory.spider_trunk
  dock_data.connected_spidertron = spidertron
  storage.spidertrons_docked[spidertron.unit_number] = dock_data.dock.unit_number

  Dock.animate_dock(dock_data, true)
  --game.print("Spidertron docked")
  --surface.create_entity{name = "flying-text", position = dock.position, text = {"flying-text.spidertron-docked"}}
  return true
end

---@param dock_data DockData
---@return nil
---@return boolean
local function update_dock(dock_data)
  local dock = dock_data.dock
  local delete = false
  if dock.valid then
    local surface = dock.surface
    local spidertron = dock_data.connected_spidertron
    if spidertron and spidertron.valid then
      -- 0.1 * 216 ~ 20km/h
      if dock.to_be_deconstructed() or spidertron.speed > 0.2 or spidertron.autopilot_destination or not math2d.bounding_box.collides_with(increase_bounding_box(dock.bounding_box, 1.7), spidertron.bounding_box) then
        -- Spidertron needs to become undocked
        dock.proxy_target_entity = nil

        storage.spidertrons_docked[spidertron.unit_number] = nil
        storage.spidertron_docks[dock.unit_number] = {dock = dock}
        Dock.animate_dock(dock_data, false)
       -- surface.create_entity{name = "flying-text", position = dock.position, text = {"flying-text.spidertron-undocked"}}
      end
    else
      if spidertron then
        -- `spidertron` is not valid
        dock_data = {dock = dock_data.dock}
      end

      -- Check if dock should initiate connection
      if not dock.to_be_deconstructed() then
        local nearby_spidertrons = surface.find_entities_filtered{type = "spider-vehicle", area = increase_bounding_box(dock.bounding_box, 0.4), force = dock.force}
        for _, nearby_spidertron in pairs(nearby_spidertrons) do
          connect_to_spidertron(dock_data, nearby_spidertron)
        end
      end
    end
  else
    delete = true
  end
  return nil, delete  -- Deletes dock from global table
end

---@param event EventData.on_tick
local function on_tick(event)
  local schedule = storage.scheduled_docks_opening[event.tick]
  if schedule then
    for _, dock_unit_number in pairs(schedule) do
      local dock_data = storage.spidertron_docks[dock_unit_number]
      if dock_data and dock_data.dock.valid then
        local open_port_sprite = rendering.draw_sprite{
          sprite = "sp-spidertron-dock-port-open",
          target = {
            entity = dock_data.dock,
            offset = util.by_pixel_hr(-9, -46),
          },
          surface = dock_data.dock.surface,
          render_layer = "object",
        }
        dock_data.open_port_sprite = open_port_sprite
      end
    end
  end
  if next(storage.spidertron_docks) then
    -- TODO Replace '20' with configurable setting?
    storage.from_k = for_n_of(storage.spidertron_docks, storage.from_k, 20, update_dock)
  end
end

Dock.events = {
  [defines.events.on_built_entity] = on_built,
  [defines.events.on_robot_built_entity] = on_built,
  [defines.events.on_space_platform_built_entity] = on_built,
  [defines.events.script_raised_revive] = on_built,
  [defines.events.script_raised_built] = on_built,
  [defines.events.on_entity_cloned] = on_built,
  [defines.events.on_object_destroyed] = on_object_destroyed,
  [defines.events.on_tick] = on_tick,
}

return Dock