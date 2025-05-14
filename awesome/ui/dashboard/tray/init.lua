local sliders = require("ui.dashboard.tray.sliders")
local buttons = require("ui.dashboard.tray.buttons")
local actions = wibox.widget {
  {
    {
      {
        { widget = buttons.sound },
        { widget = buttons.nightmode },
        { widget = buttons.dnd },
        { widget = buttons.terminal },
        layout = wibox.layout.flex.horizontal,
        spacing = 15,
      },
      {
        {
          sliders.volume,
          layout = wibox.layout.fixed.horizontal,
        },
        {
          sliders.brightness,
          layout = wibox.layout.fixed.horizontal,
        },
        layout = wibox.layout.flex.vertical,
        spacing = 0,
      },
      layout = wibox.layout.flex.vertical,
      spacing = 30,
    },
    widget = wibox.container.margin,
    top = 20,
    bottom = 20,
    left = 35,
    right = 35,
  },
  widget = wibox.container.background,
  bg = beautiful.bg_1,
  forced_height = dpi(240),
  shape = help.rrect()
}

return actions
