local bslider = wibox.widget {
  bar_shape = help.rrect(),
  bar_height = 6,
  bar_color = beautiful.bg_2,
  bar_active_color = beautiful.bg_3,
  handle_shape = gears.shape.circle,
  handle_color = beautiful.blue,
  handle_width = 15,
  value = 25,
  widget = wibox.widget.slider,
}


local bri_slider = wibox.widget {
  {
    widget = wibox.widget.imagebox,
    image = gears.filesystem.get_configuration_dir() .. "/core/theme/icons/google/sun.svg",
    stylesheet = " * { stroke: " .. beautiful.fg .. " }",
    forced_width = 28,
    valign = "center",
    halign = "center",
  },
  bslider,
  layout = wibox.layout.fixed.horizontal,
  spacing = 15,
}

bslider:connect_signal("property::value", function(_, value)
  awful.spawn.with_shell("brightnessctl s " .. value .. "%")
end)

--------

local vslider = wibox.widget {
  bar_shape = help.rrect(),
  bar_height = 6,
  bar_color = beautiful.bg_2,
  bar_active_color = beautiful.bg_3,
  handle_shape = gears.shape.circle,
  handle_color = beautiful.blue,
  handle_width = 15,
  value = 65,
  widget = wibox.widget.slider,
}


local vol_slider = wibox.widget {
  {
    widget = wibox.widget.imagebox,
    image = gears.filesystem.get_configuration_dir() .. "/core/theme/icons/google/volume-up.svg",
    stylesheet = " * { stroke: " .. beautiful.fg .. " }",
    forced_width = 28,
    valign = "center",
    halign = "center",
  },
  vslider,
  layout = wibox.layout.fixed.horizontal,
  spacing = 15,
}

vslider:connect_signal("property::value", function(_, value)
  awful.spawn.with_shell("amixer -c 2 set Speaker " .. value .. "%")
end)


return {
  volume = vol_slider,
  brightness = bri_slider,
}
