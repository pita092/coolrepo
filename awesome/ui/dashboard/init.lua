local M = {}
M.control_c = wibox({
  shape = help.rrect(),
  width = dpi(600),
  height = 630,
  bg = beautiful.bg_2,
  fg = beautiful.fg,
  border_width = 0,
  border_color = beautiful.fg,
  margins = 20,
  ontop = true,
  visible = false,
  x = dpi(1704),
  y = dpi(0),
})


M.control_c:setup {
  {
    {
      {
        require("ui.dashboard.title"),
        require("ui.dashboard.personal"),
        {
          require("ui.dashboard.cal")(),
          widget = wibox.container.background,
          bg = beautiful.bg_3,
          shape = help.rrect(),
        },
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(7),
      },
      layout = wibox.layout.fixed.vertical,
      widget = wibox.container.place,
      spacing = dpi(40),
    },
    widget = wibox.container.margin,
    margins = 7
  },
  layout = wibox.layout.fixed.vertical,
}

return M
