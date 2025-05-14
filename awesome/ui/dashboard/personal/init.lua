local handle = io.popen("cut -d' ' -f1 /proc/uptime")
local uptime = handle:read("*n")
handle:close()
uptime = math.floor((uptime % 3600) / 60)


local my_time    = wibox.widget {
  format = "<i>" .. help.colortext('%H' .. help.colortext(':', beautiful.blue) .. '%M', beautiful.fg) .. "</i>",
  widget = wibox.widget.textclock,
  font = beautiful.font_custom .. "50",
  halign = "left",
}

local my_uptime  = wibox.widget {
  markup = "uptime" .. help.colortext(":", beautiful.blue) .. " " .. help.colortext(uptime, beautiful.fg) .. "<i>m</i>",
  widget = wibox.widget.textbox,
  font = beautiful.icon,
  halign = "left",
}
local my_pictrue = wibox.widget({
  {
    halign = 'center',
    valign = 'center',
    forced_width = 250,
    forced_height = 1000,
    clip_shape = help.rrect(),
    widget = wibox.widget.imagebox,
    image = config_dir .. "core/theme/pfp/awesomewmpita.png",
  },
  widget = wibox.container.background,
  bg = beautiful.bg_2,
  shape = help.rrect(),
})


local widget = wibox.widget {
  {
    {
      {
        {
          my_time,
          my_uptime,
          layout = wibox.layout.fixed.vertical
        },
        widget = wibox.container.margin,
        margins = 10
      },
      {
        {
          my_pictrue,
          layout = wibox.layout.fixed.vertical,
        },
        widget = wibox.container.margin,
      },
      spacing = 35,
      layout = wibox.layout.fixed.horizontal,
    },
    widget = wibox.container.margin,
    margins = 10
  },
  widget = wibox.container.background,
  bg = beautiful.bg_1,
  forced_height = dpi(300),
  shape = help.rrect(),
}
gears.timer {
  timeout   = 60,
  call_now  = true,
  autostart = true,
  callback  = function()
    handle = io.popen("cut -d' ' -f1 /proc/uptime")
    uptime = handle:read("*n")
    handle:close()
    uptime = math.floor(uptime / 60)
    my_uptime.markup = "uptime" ..
        help.colortext(":", beautiful.blue) .. " " .. help.colortext(uptime, beautiful.fg) .. "<i>m</i>"

    my_time.format = "<i>" .. help.colortext('%H' .. help.colortext(':', beautiful.blue) .. '%M', beautiful.fg) .. "</i>"
  end
}

return widget
