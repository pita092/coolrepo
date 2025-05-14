local M = {}
M.control_c = wibox({
  shape = help.rrect(),
  width = dpi(600),
  height = 250,
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
      require("ui.settings.title"),

      {
        require("ui.settings.sound"),
        layout = wibox.layout.fixed.vertical,
      },
      layout = wibox.layout.fixed.vertical,
      widget = wibox.container.place,
      spacing = dpi(7),
    },
    widget = wibox.container.margin,
    margins = 7
  },
  layout = wibox.layout.fixed.vertical,
}

return M
