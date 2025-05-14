-- widget = wibox.container.margin,

local profile = wibox.widget({
  {
    {
      {
        require("ui.lock.widgets.prof.image"),
        require("ui.lock.widgets.prof.name"),
        layout = wibox.layout.fixed.horizontal,
        spacing = dpi(12),
      },
      widget = wibox.container.margin,
      margins = dpi(12)
    },
    layout = wibox.layout.fixed.vertical,
    spacing = dpi(12)
  },
  widget = wibox.container.background,
  bg = beautiful.bg_1,
  forced_width = 350,
  forced_height = 150,
  -- shape = function(cr, width, height)
  --   gears.shape.partially_rounded_rect(cr, width, height, true, true, false, false, 15)
  -- end,
  shape = help.rrect()
})

return profile
