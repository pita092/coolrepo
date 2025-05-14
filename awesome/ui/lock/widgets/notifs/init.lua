local notif_center = {}
local notifications = {}

local empty_placeholder = wibox.widget {
  {
    {
      {
        text = "No notifications",
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox,
        font = beautiful.font_custom .. "16",
      },
      fg = beautiful.fg_normal,
      widget = wibox.container.background,
    },
    layout = wibox.layout.stack
  },
  widget = wibox.container.background,
  forced_height = 150,
}

notif_center.widget = wibox.widget {
  {
    id = "notif_list",
    layout = wibox.layout.fixed.vertical,
    spacing = 10,
  },
  id = "notif_container",
  widget = wibox.container.background,
  forced_width = 50,
}

local function update_notification_list()
  local list = notif_center.widget:get_children_by_id("notif_list")[1]
  list:reset()

  if #notifications == 0 then
    list:add(empty_placeholder)
  else
    for _, notif_entry in ipairs(notifications) do
      list:add(notif_entry.widget)
    end
  end
end

naughty.connect_signal("added", function(n)
  n.timeout = 0
  local icon = wibox.widget {
    {
      image = n.icon or config_dir .. "/core/theme/icons/google/bell.svg",
      stylesheet = " * { stroke: " .. beautiful.fg_3 .. " }",
      resize = true,
      widget = wibox.widget.imagebox,
      forced_width = 50,
      forced_height = 50,
    },
    widget = wibox.container.margin,
    margins = dpi(5),
  }
  local notif = wibox.widget {
    {
      icon,
      {
        {
          {
            markup = "<b>" .. n.title .. "</b>",
            widget = wibox.widget.textbox
          },
          {
            text = n.message,
            widget = wibox.widget.textbox
          },
          layout = wibox.layout.fixed.vertical,
          spacing = 2,
        },
        widget = wibox.container.margin,
        margins = 5,
      },
      layout = wibox.layout.align.horizontal,
      spacing = 12
    },
    bg = beautiful.bg_1,
    widget = wibox.container.background,
    shape = help.rrect(),
    forced_width = 150
  }
  notif:buttons(gears.table.join(
    awful.button({}, 1, function()
      naughty.destroy(n)
    end)
  ))
  table.insert(notifications, 1, {
    notification = n,
    widget = notif
  })

  update_notification_list()
end)

naughty.connect_signal("destroyed", function(n)
  for i, notif_entry in ipairs(notifications) do
    if notif_entry.notification == n then
      table.remove(notifications, i)
      break
    end
  end

  update_notification_list()
end)

update_notification_list()
return notif_center
