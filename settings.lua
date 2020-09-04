--[[data:extend({
    {
        type = "string-setting",
        name = "spidertron-waypoints-use-patrol-remote-a",
        setting_type = "startup",
        default_value = "contextual",
        allowed_values = {"never", "contextual", "always"}
    }
})]]

data:extend({
    {
        type = "bool-setting",
        name = "spidertron-waypoints-include-waypoint",
        setting_type = "runtime-global",
        default_value = true
    }
})
data:extend({
    {
        type = "bool-setting",
        name = "spidertron-waypoints-include-patrol",
        setting_type = "runtime-global",
        default_value = true
    }
})