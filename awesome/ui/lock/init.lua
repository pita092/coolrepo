local lock_wibox = wibox({
  screen = awful.screen.focused(),
  visible = false,
  ontop = true,
  type = "dock",
  height = 600,
  width = 900,
})


lock_wibox:setup {
  {
    {
      {
        {
          require("ui.lock.widgets.title"),
          widget = wibox.container.background,
          bg = beautiful.bg_1,
          forced_height = 40,
          shape = help.rrect(),
        },
        spacing = dpi(7),
        {
          {
            {
              {
                require("ui.lock.widgets.prof"),
                layout = wibox.layout.fixed.vertical,
              },
              {
                require("ui.lock.widgets.spotify"),
                layout = wibox.layout.fixed.vertical,
              },
              {
                require("ui.lock.widgets.time"),
                layout = wibox.layout.fixed.vertical,
              },
              spacing = dpi(7),
              layout = wibox.layout.fixed.horizontal,
            },
            {
              forced_height = dpi(0),
              shape = gears.shape.line,
              widget = wibox.widget.separator
            },
            {
              nil,
              {
                {
                  {
                    {
                      widget = wibox.widget.textbox,
                      markup = "<i>notifications</i>",
                      halign = "center",
                      font = beautiful.icon,
                      forced_width = 524,
                    },
                    widget = wibox.container.margin,
                    margins = dpi(5),
                  },
                  widget = wibox.container.background,
                  bg = beautiful.bg_1,
                  shape = help.rrect(),
                },
                require("ui.lock.widgets.notifs").widget,
                widget = wibox.container.background,
                bg = beautiful.bg,
                layout = wibox.layout.fixed.vertical,
                spacing = dpi(10),
              },
              {
                {
                  {
                    {
                      widget = wibox.widget.textbox,
                      markup = "<i>sysinfo</i>",
                      halign = "center",
                      font = beautiful.icon,
                    },
                    widget = wibox.container.margin,
                    margins = dpi(5),
                  },
                  widget = wibox.container.background,
                  bg = beautiful.bg_1,
                  shape = help.rrect(),
                },
                require("ui.lock.widgets.sys"),
                layout = wibox.layout.fixed.vertical,
              },
              layout = wibox.layout.fixed.horizontal,
              spacing = dpi(7)
            },
            layout = wibox.layout.fixed.vertical,
            spacing = dpi(7),
          },
          layout = wibox.layout.fixed.horizontal,
        },
        layout = wibox.layout.fixed.vertical,
      },
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.margin,
    margins = dpi(7)
  },
  widget = wibox.container.background,
  bg = beautiful.bg_2,
  shape = help.rrect(),
}

awesome.connect_signal("toggle::lock", function()
  local is_visible = lock_wibox.visible and lock_wibox.y > -lock_wibox.height
  if not is_visible then
    lock_wibox.visible = true
    awful.placement.top(
      lock_wibox,
      { honor_workarea = true, margins = { top = -lock_wibox.height } }
    )

    if lock_wibox.animation then
      lock_wibox.animation:stop()
    end
    lock_wibox.animation = animation.slide_y(lock_wibox, {
      start = -lock_wibox.height,
      target = 200,
      duration = 0.3,
      easing = animation.easing.sinusoidal,
      complete = function()
        lock_wibox.animation = nil
      end
    })
  else
    awesome.emit_signal("unlock::lock")
  end
end)


awesome.connect_signal("unlock::lock", function()
  if lock_wibox.animation then
    lock_wibox.animation:stop()
  end

  lock_wibox.animation = animation.slide_y(lock_wibox, {
    start = 200,
    target = -lock_wibox.height,
    duration = 0.3,
    easing = animation.easing.sinusoidal,
    complete = function()
      lock_wibox.visible = false
      lock_wibox.animation = nil
    end
  })
end)
