--i stole this
--from chadcat/namish

local datewidget = function(date, weekend, notIn)
  weekend = weekend or false
  return wibox.widget {
    markup = notIn and help.colortext(date, beautiful.fg_3)
        or (weekend and help.colortext(date, beautiful.fg) or tostring(date)),
    halign = 'center',
    font   = beautiful.font_custom .. " 18",
    widget = wibox.widget.textbox
  }
end

local daywidget = function(day, weekend)
  return wibox.widget {
    markup = help.colortext(weekend and day or day, beautiful.fg_3),
    halign = 'center',
    font   = beautiful.font_custom .. " 18",
    widget = wibox.widget.textbox
  }
end

local currwidget = function(day)
  return wibox.widget {
    markup = help.colortext(day, beautiful.blue),
    halign = 'center',
    font   = beautiful.font_custom .. " 18",
    widget = wibox.widget.textbox
  }
end

local title = wibox.widget {
  font = beautiful.font_custom .. " Bold 18",
  widget = wibox.widget.textbox,
  halign = 'center',
}

local theGrid = wibox.widget {
  forced_num_rows = 7,
  forced_num_cols = 7,
  vertical_spacing = dpi(10),
  horizontal_spacing = dpi(10),
  min_cols_size = dpi(30),
  min_rows_size = dpi(30),
  homogeneous = true,
  layout = wibox.layout.grid,
}

local updateCalendar = function(date)
  title.markup = help.colortext(os.date("%B %Y", os.time(date)), beautiful.blue)

  theGrid:reset()

  for _, w in ipairs { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" } do
    theGrid:add(daywidget(w, w == "Sun" or w == "Sat"))
  end

  local firstDate = os.date("*t", os.time({ day = 1, month = date.month, year = date.year }))
  local lastDate = os.date("*t", os.time({ day = 0, month = date.month + 1, year = date.year }))
  local days_to_add_at_month_start = firstDate.wday - 1
  local days_to_add_at_month_end = 42 - lastDate.day - days_to_add_at_month_start
  local prev_month_last_day = os.date("*t", os.time({ year = date.year, month = date.month, day = 0 })).day

  local row, col = 2, 1

  for day = prev_month_last_day - days_to_add_at_month_start + 1, prev_month_last_day do
    theGrid:add(datewidget(day, false, true))
  end

  for day = 1, lastDate.day do
    if day == date.day then
      theGrid:add(currwidget(day))
    else
      theGrid:add(datewidget(day, col == 1 or col == 7, false))
    end
    col = col % 7 + 1
    if col == 1 then row = row + 1 end
  end

  for day = 1, days_to_add_at_month_end do
    theGrid:add(datewidget(day, false, true))
  end
end

return function()
  local curr = os.date("*t")
  updateCalendar(curr)


  return wibox.widget {
    {
      {
        {
          {
            {
              markup = help.colortext(" ", beautiful.fg_3),
              font = beautiful.icofont,
              widget = wibox.widget.textbox,
              buttons = awful.button({}, 1, function()
                curr = os.date("*t", os.time({
                  day = curr.day,
                  month = curr.month - 1,
                  year = curr.year
                }))
                updateCalendar(curr)
              end)
            },
            widget = wibox.container.margin,
            left = 38,
          },
          title,
          {
            {
              markup = help.colortext(" ", beautiful.fg_3),
              font = beautiful.icofont,
              widget = wibox.widget.textbox,
              buttons = awful.button({}, 1, function()
                curr = os.date("*t", os.time({
                  day = curr.day,
                  month = curr.month + 1,
                  year = curr.year
                }))
                updateCalendar(curr)
              end)
            },
            widget = wibox.container.margin,
            right = 38,
          },
          layout = wibox.layout.align.horizontal
        },
        {
          theGrid,
          widget = wibox.container.place,
          halign = 'center',
        },
        spacing = 17,
        layout = wibox.layout.fixed.vertical
      },
      widget = wibox.container.margin,
      margins = 40
    },
    shape = help.rrect(),
    widget = wibox.container.background,
    bg = beautiful.bg_1
  }
end
