local awesome_lua_version = _VERSION:match("%d+%.%d+")
local username = io.popen("whoami"):read("*a"):gsub("\n", "")
local hostname = io.popen("hostname"):read("*a"):gsub("\n", "")



local text = wibox.widget({
  {
    {
      {
        wibox.widget {
          markup = help.colortext("Welcome", beautiful.red) .. ",<i>" .. help.colortext(username, beautiful.blue) .. "</i>!",
          widget = wibox.widget.textbox,
          font   = beautiful.icon,
        },
        require("ui.lock.widgets.prof.date"),
        layout = wibox.layout.fixed.vertical
      },
      {
        {
          wibox.widget {
            markup = help.colortext(" ", beautiful.green),
            widget = wibox.widget.textbox,
            font   = beautiful.icon,
          },
          wibox.widget {
            markup = "<i>" .. username .. "</i>@" .. hostname,
            widget = wibox.widget.textbox,
            font   = beautiful.font,
          },
          layout = wibox.layout.fixed.horizontal
        },
        {
          wibox.widget {
            markup = help.colortext(" ", beautiful.green),
            widget = wibox.widget.textbox,
            font   = beautiful.icon,
          },
          wibox.widget {
            markup = "<i>lua</i> " .. awesome_lua_version,
            widget = wibox.widget.textbox,
            font   = beautiful.font,
          },
          layout = wibox.layout.fixed.horizontal
        },
        layout = wibox.layout.fixed.vertical
      },

      layout = wibox.layout.fixed.vertical,
      spacing = dpi(5),
    },
    layout = wibox.layout.fixed.horizontal,
    spacing = dpi(15),
  },
  widget = wibox.container.background,
  bg = beautiful.bg_1,
})

return text
