local time = wibox.widget({
  {
    widget = wibox.widget.textclock,
    format = help.colortext('%H\n%M', beautiful.blue),
    font = beautiful.font_custom .. "32",
    halign = "center",
  },
  widget = wibox.container.background,
  bg = beautiful.bg_1,
  forced_width = 105,
  forced_height = 150,
  shape = help.rrect()
})

return time
