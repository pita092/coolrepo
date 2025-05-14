local imagebox = wibox.widget {
  widget = wibox.widget.imagebox,
  image = config_dir .. "core/theme/icons/google/volume-up.svg",
  stylesheet = " * { stroke: " .. beautiful.fg_3 .. " }",
  forced_width = 5,
  valign = "center",
  halign = "center",
}

local sound = wibox.widget {
  {
    {
      imagebox,
      widget = wibox.container.margin,
    },
    widget = wibox.container.margin,
    margins = 15,
  },
  widget = wibox.container.background,
  bg = beautiful.bg_3,
  shape = help.rrect()
}

local status = true
sound:buttons {
  awful.button({}, 1, function()
    status = not status
    if status then
      sound.bg = beautiful.blue
      imagebox.image = config_dir .. "core/theme/icons/google/volume-down.svg"
      awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ 0%")
    else
      sound.bg = beautiful.bg_3
      imagebox.image = config_dir .. "core/theme/icons/google/volume-up.svg"
      awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ 45%")
    end
  end),
}

local imagebox = wibox.widget {
  widget = wibox.widget.imagebox,
  image = config_dir .. "core/theme/icons/google/sun.svg",
  stylesheet = " * { stroke: " .. beautiful.fg_3 .. " }",
  forced_width = 5,
  valign = "center",
  halign = "center",
}

local nightmode = wibox.widget {
  {
    {
      imagebox,
      widget = wibox.container.margin,
    },
    widget = wibox.container.margin,
    margins = 15,
  },
  widget = wibox.container.background,
  bg = beautiful.bg_3,
  shape = help.rrect()
}
local status2 = true
nightmode:buttons {
  awful.button({}, 1, function()
    status2 = not status2
    if status2 then
      imagebox.image = config_dir .. "core/theme/icons/google/sun.svg"
      nightmode.bg = beautiful.bg_3
      awful.spawn.with_shell("redshift -x")
    else
      imagebox.image = config_dir .. "core/theme/icons/google/moon.svg"
      nightmode.bg = beautiful.blue
      awful.spawn.with_shell("redshift -O 3000")
    end
  end),
}


local imagebox = wibox.widget {
  widget = wibox.widget.imagebox,
  image = config_dir .. "core/theme/icons/google/dnd.svg",
  stylesheet = " * { stroke: " .. beautiful.fg_3 .. " }",
  forced_width = 5,
  valign = "center",
  halign = "center",
}

local dnd = wibox.widget {
  {
    {
      imagebox,
      widget = wibox.container.margin,
    },
    widget = wibox.container.margin,
    margins = 15,
  },
  widget = wibox.container.background,
  bg = beautiful.bg_3,
  shape = help.rrect()
}
local status3 = true
dnd:buttons {
  awful.button({}, 1, function()
    status3 = not status3
    if status3 then
      dnd.bg = beautiful.bg_3
      naughty.resume()
    else
      dnd.bg = beautiful.blue
      naughty.suspend()
    end
  end),
}


local imagebox = wibox.widget {
  widget = wibox.widget.imagebox,
  image = config_dir .. "core/theme/icons/google/badge.svg",
  stylesheet = " * { stroke: " .. beautiful.fg_3 .. " }",
  forced_width = 5,
  valign = "center",
  halign = "center",
}

local terminal = wibox.widget {
  {
    {
      imagebox,
      widget = wibox.container.margin,
    },
    widget = wibox.container.margin,
    margins = 15,
  },
  widget = wibox.container.background,
  bg = beautiful.bg_3,
  shape = help.rrect()
}
local status4 = true
terminal:buttons {
  awful.button({}, 1, function()
    status4 = not status4
    if status4 then
      terminal.bg = beautiful.bg_3
      awful.spawn.with_shell("bash -c 'xcol'")
    else
      terminal.bg = beautiful.blue
      awful.spawn.with_shell("bash -c 'xcol'")
    end
  end),
}


return {
  sound = sound,
  nightmode = nightmode,
  dnd = dnd,
  terminal = terminal,
}
