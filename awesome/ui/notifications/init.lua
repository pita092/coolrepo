naughty.connect_signal("request::display", function(n)
  n.timeout = 5
  local icon = wibox.widget {
    {
      image = n.icon or config_dir .. "/core/theme/icons/google/bell.svg",
      stylesheet = " * { stroke: " .. beautiful.fg_3 .. " }",
      resize = true,
      widget = wibox.widget.imagebox,
      forced_width = 30,
      forced_height = 50,
    },
    widget = wibox.container.margin,
    top = 10,
  }
  local app_name = wibox.widget {
    text = n.app_name,
    font = beautiful.font_custom .. "18",
    widget = wibox.widget.textbox,
  }
  local title = wibox.widget {
    text = n.title or "Notification",
    font = beautiful.font_custom .. "15",
    widget = wibox.widget.textbox,
  }
  local message = wibox.widget {
    text = n.message or "This is a message",
    font = "JetBrainsMonoNL 16",
    widget = wibox.widget.textbox,
  }

  local progressbar = wibox.widget({
    value = 0,
    max_value = 1,
    min_value = 0,
    forced_width = 30,
    forced_height = 30,
    border_width = 3,
    color = beautiful.blue,
    border_color = beautiful.bg_3,
    widget = wibox.container.radialprogressbar,
    shape = help.rrect(dpi(6)),
  })

  --based animation
  local base_r, base_g, base_b = 0x83, 0xa5, 0xba
  animation.animate({
    start = 0,
    target = 1,
    duration = 4.7,
    easing = animation.easing.linear,
    update = function(progress)
      local r = math.floor(base_r + (0x90 - base_r) * progress)
      local g = math.floor(base_g + (0x90 - base_g) * math.sin(progress * math.pi))
      local b = math.floor(base_b + (0xFF - base_b) * math.cos(progress * math.pi))

      progressbar:set_color(string.format("#%02x%02x%02x", r, g, b))
      progressbar:set_value(progress)
    end,
    complete = function()
      naughty.notification_closed(n)
    end
  })

  local thing = wibox.widget({
    {
      {
        app_name,
        nil,
        progressbar,
        layout = wibox.layout.align.horizontal,
      },
      left = 10,
      right = 10,
      top = 5,
      bottom = 5,
      widget = wibox.container.margin,
    },
    widget = wibox.container.background,
    bg = beautiful.bg_2,

  })

  local thing2 = wibox.widget({
    title,
    message,
    layout = wibox.layout.fixed.vertical,
    spacing = 0,
  })

  naughty.layout.box {
    notification = n,
    timeout = 10,
    type = "notification",
    shape = help.rrect(),
    widget_template = {
      {
        {
          thing,
          {
            {
              icon,
              thing2,
              layout = wibox.layout.fixed.horizontal,
              spacing = 18,
            },
            {
              naughty.list.actions,
              layout  = wibox.layout.fixed.horizontal,
              spacing = 15,
            },
            margins = 10,
            widget = wibox.container.margin,
          },
          spacing = 0,
          layout = wibox.layout.fixed.vertical,
        },
        widget = wibox.container.margin,
      },
      bg = beautiful.bg,
      widget = wibox.container.background,
      border_width = 0,
      border_color = beautiful.blue,
      forced_width = 500,
    },
  }
end)
