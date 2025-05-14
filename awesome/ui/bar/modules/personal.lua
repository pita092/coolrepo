local picture = wibox.widget({
  widget = wibox.widget.imagebox,
  image = config_dir .. "core/theme/pfp/pfp.svg",
  halign = 'center',
  valign = 'center',
  resize = true,
  clip_shape = help.rrect(),
})

local widget = wibox.widget({
  {
    picture,
    widget = wibox.container.margin,
    margins = dpi(5),
  },
  widget = wibox.container.background,
  bg = beautiful.bg_1,
  shape = help.rrect(),
  forced_width = 40,
})

help.addhover(widget, beautiful.bg_1, beautiful.blue)

widget.buttons = gears.table.join(
  awful.button({}, 1, function()
    awesome.emit_signal("toggle::lock")
  end)
)


return widget
