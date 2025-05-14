local systray = wibox.widget.systray()
systray:set_base_size(5)
local systray_widget = wibox({
  visible = false,
  ontop = true,
  height = 50,
  width = 250,
  bg = beautiful.bg_3,
  shape = help.rrect(),
})

systray_widget:setup({
  systray,
  widget = wibox.container.margin,
  margins = 5
})

awesome.connect_signal("toggle::systray", function()
  local is_visible = systray_widget.visible and systray_widget.x < 1765

  if is_visible then
    systray_widget.visible = false
  else
    systray_widget.visible = true
    awful.placement.bottom_right(
      systray_widget,
      { honor_workarea = true, margins = { bottom = 22, left = 100 } }
    )

    if systray_widget.animation then
      systray_widget.animation:stop()
    end

    systray_widget.animation = animation.slide(systray_widget, {
      start = systray_widget.x,
      target = 1665,
      duration = 0.2,
      complete = function()
        systray_widget.animation = nil
      end
    })
  end
end)
local widget = wibox.widget {
  widget = wibox.container.background,
  shape = help.rrect(3),
  bg = beautiful.bg,
  {
    {
      widget = wibox.widget.imagebox(config_dir .. "core/theme/icons/google/arrow_up.svg"),
      halign = "center",
    },
    layout = wibox.layout.fixed.vertical,
  },
  forced_width = 40
}

help.addhover(widget, beautiful.bg, beautiful.blue)

widget.buttons = gears.table.join(
  awful.button({}, 1, function()
    awesome.emit_signal("toggle::systray")
  end)
)



return widget
