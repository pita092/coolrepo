local image_path = "/tmp/spotify_tmp.png"

local function is_spotify_playing(callback)
  awful.spawn.easy_async_with_shell("playerctl -p spotify status 2>/dev/null", function(stdout)
    stdout = stdout:gsub("^%s*(.-)%s*$", "%1")
    local is_playing = (stdout == "Playing")
    if callback then
      callback(is_playing)
    end
  end)
end

local cover_art      = wibox.widget({
  halign = 'center',
  valign = 'center',
  forced_width = 130,
  clip_shape = help.rrect(),
  widget = wibox.widget.imagebox,
  image = config_dir .. "core/theme/icons/google/headphones.svg",
})
local song_text      = wibox.widget {
  text   = "",
  align  = "center",
  valign = "center",
  widget = wibox.widget.textbox
}

local artist_text    = wibox.widget {
  text   = "",
  align  = "center",
  valign = "center",
  widget = wibox.widget.textbox
}

local next           = wibox.widget {
  align = 'center',
  font = beautiful.icon .. " 22",
  text = ' 󰒭 ',
  widget = wibox.widget.textbox,
  buttons = {
    awful.button({}, 1, function()
      awful.spawn("playerctl -p spotify next")
    end)
  },
}

local prev           = wibox.widget {
  align = 'center',
  font = beautiful.icon .. " 22",
  text = ' 󰒮 ',
  widget = wibox.widget.textbox,
  buttons = {
    awful.button({}, 1, function()
      awful.spawn("playerctl -p spotify previous")
    end)
  },
}
local play           = nil
play                 = wibox.widget {
  align = 'center',
  font = beautiful.icon .. " 22",
  widget = wibox.widget.textbox,
  markup = '',
  buttons = {
    awful.button({}, 1, function()
      is_spotify_playing(function(playing)
        play.markup = playing and "" or ""
        awful.spawn("playerctl -p spotify play-pause")
      end)
    end)
  },
}

local spotify_widget = wibox.widget {
  {
    {
      {
        {
          {
            prev,
            play,
            next,
            layout = wibox.layout.align.vertical,
          },
          widget = wibox.container.background,
          bg = beautiful.bg_2,
          shape = help.rrect(),
        },
        cover_art,
        {
          {
            song_text,
            artist_text,
            layout = wibox.layout.align.vertical,
          },
          widget = wibox.container.margin,
          top    = dpi(25),
        },
        spacing = dpi(15),
        layout = wibox.layout.fixed.horizontal
      },
      layout = wibox.layout.align.horizontal
    },
    widget = wibox.container.margin,
    margins = dpi(3)
  },
  widget = wibox.container.background,
  bg = beautiful.bg_1,
  shape = help.rrect(),
  forced_width = 420,
  forced_height = 150,
}

local function update_spotify()
  awful.spawn.easy_async_with_shell(
    [[
        playerctl -p spotify metadata --format '{{artist}}|{{title}}|{{mpris:artUrl}}'
        ]],
    function(stdout)
      local artist, title, art_url = stdout:match("^(.-)|(.-)|(.-)$")

      if artist and title then
        song_text.markup = "<i>" .. title .. "</i>"
        artist_text.markup = "<b>" .. artist .. "</b>"

        awful.spawn.easy_async(config_dir .. "/core/scripts/spotfetch", function()
          local image = gears.surface.load_uncached_silently(image_path)
          if image then
            cover_art:set_image(image)
            gears.surface.load_uncached_silently(nil)
          end
        end)
      else
        cover_art:set_image(config_dir .. "core/theme/icons/google/headphones.svg")
        song_text.text = "Nothing Playing"
        artist_text.text = "None"
      end
    end
  )
end

gears.timer {
  timeout   = 1.1,
  call_now  = true,
  autostart = true,
  callback  = function()
    is_spotify_playing(function(playing)
      play.markup = playing and "" or ""
    end)
    update_spotify()
  end
}

return spotify_widget
