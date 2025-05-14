local function format_date()
  return os.date("%A, %B %d")
end

-- Date widget
local date_widget = wibox.widget {
  markup = "<span font='14' color='#FFFFFF'>" .. format_date() .. "</span>",
  widget = wibox.widget.textbox,
}

-- Update date every minute
gears.timer {
  timeout = 60,
  call_now = true,
  autostart = true,
  callback = function()
    date_widget.markup = "<span font='14' color='#FFFFFF'>" .. format_date() .. "</span>"
  end
}

return date_widget
