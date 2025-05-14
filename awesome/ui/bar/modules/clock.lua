local my_time = wibox.widget {
  format = help.colortext(' %H:%M ', beautiful.fg),
  widget = wibox.widget.textclock,
  font = beautiful.icon,
}
local my_date = wibox.widget {
  format = help.colortext('%B %d ', beautiful.fg),
  widget = wibox.widget.textclock,
  font = beautiful.font,
}

local widget = wibox.widget({
  my_time,
  my_date,
  widget = wibox.container.margin,
  layout = wibox.layout.fixed.horizontal,
  margins = dpi(5),
})


local thing = wibox.widget
    {

      {
        {
          my_time,
          my_date,
          widget = wibox.container.margin,
          layout = wibox.layout.fixed.horizontal,
          margins = dpi(5),
        },
        widget = wibox.container.margin,
        margins = dpi(8),
      },
      shape = help.rrect(),
      widget = wibox.container.background,
      bg = beautiful.bg_1,
    }

thing.buttons = gears.table.join(
  awful.button({}, 1, function()
    awesome.emit_signal("toggle::dashboard")
  end)
)
help.addhover(thing, beautiful.bg_1, beautiful.blue)
return thing
