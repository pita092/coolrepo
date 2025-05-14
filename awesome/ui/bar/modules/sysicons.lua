local internet = wibox.widget({
  widget = wibox.widget.imagebox,
  image = config_dir .. "/core/theme/icons/google/wifi.svg",
  halign = 'center',
  valign = 'center',
  resize = true,
  clip_shape = help.rrect(),
})

local widget = wibox.widget({
  {
    internet,
    widget = wibox.container.margin,
    margins = dpi(5),
  },
})

help.addhover(widget, beautiful.bg_1, beautiful.blue)



gears.timer {
  timeout   = 10,
  call_now  = true,
  autostart = true,
  callback  = function()
    awful.spawn.easy_async_with_shell(
      "ping -c 1 8.8.8.8 >/dev/null 2>&1 && echo up || echo down",
      function(stdout)
        internet.image = stdout:match("up") and config_dir .. "/core/theme/core/google/wifi.svg" or
            config_dir .. "/core/theme/core/google/wifi.svg"
      end
    )
  end
}


return widget
