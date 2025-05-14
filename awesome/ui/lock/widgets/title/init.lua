local widget = wibox.widget {
  {
    {
      require("ui.lock.widgets.title.title"),
      widget = wibox.container.background,
      bg = beautiful.bg_1,
      shape = help.rrect(),
      forced_width = 40
    },
    nil,
    {
      {
        {
          widget = wibox.widget.imagebox,
          image = config_dir .. "core/theme/icons/google/dashboard.svg",
          align = "center",
          valign = "center",
        },
        left = 5,
        right = 5,
        top = 5,
        bottom = 5,
        widget = wibox.container.margin
      },
      widget = wibox.container.background,
      bg = beautiful.bg_1,
      shape = help.rrect(),
      forced_width = 38
    },
    layout = wibox.layout.align.horizontal
  },
  widget = wibox.container.background,
  bg = beautiful.bg_1,
  forced_height = 40,
  shape = help.rrect(),
}

return widget

