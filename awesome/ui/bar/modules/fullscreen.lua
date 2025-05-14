local fullscreen = function()
  local c = client.focus
  if c then
    c.maximized = not c.maximized
    c:raise()

    local s = c.screen
    if s.sidebar then
    end
  end
end

local icon = wibox.widget({
  widget = wibox.widget.textbox,
  markup = help.colortext("", beautiful.fg),
  font = beautiful.icon,
})

local widget = wibox.widget({
  {
    icon,
    widget = wibox.container.margin,
    left = 11
  },
  widget = wibox.container.background,
  bg = beautiful.bg_1,
  shape = help.rrect(),
  forced_width = 40,
})

help.addhover(widget, beautiful.bg_1, beautiful.blue)
widget.buttons = gears.table.join(
  awful.button({}, 1, function()
    fullscreen()
  end)
)


return widget
