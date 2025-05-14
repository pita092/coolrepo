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
  clip_shape = help.rrect(),
  resize = true,
  widget = wibox.widget.imagebox,
  image = help.cropSurface(1.71, gears.surface.load_uncached(beautiful.nosongpic)),
})
local song_text      = wibox.widget {
  text   = "",
  widget = wibox.widget.textbox
}

local artist_text    = wibox.widget {
  text   = "",
  widget = wibox.widget.textbox
}

local next           = wibox.widget {
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
    nil,
    {
      cover_art,
      {
        {
          widget = wibox.widget.textbox,
        },
        bg = {
          type = "linear",
          from = { 0, 0 },
          to = { 150, 0 },
          stops = { { 0, beautiful.bg_2 .. "ff" }, { 1, beautiful.bg_2 .. '55' } }
        },
        shape = help.rrect(),
        widget = wibox.container.background,
      },
      {
        {
          {
            song_text,
            artist_text,
            layout = wibox.layout.align.vertical,
            valign = "left"
          },
          widget = wibox.container.margin,
          top    = dpi(25),
        },
        nil,
        layout = wibox.layout.align.vertical
      },

      layout = wibox.layout.stack,
    },
    {
      {
        {
          {
            prev,
            play,
            next,
            layout = wibox.layout.align.vertical,
          },
          widget = wibox.container.margin,
          top = 15,
          bottom = 15,
          left = 10,
          right = 10,
        },
        shape = help.rrect(),
        widget = wibox.container.background,
        bg = beautiful.bg_1,
      },
      widget = wibox.container.margin,
    },
    layout = wibox.layout.align.horizontal,
  },
  widget = wibox.container.margin,
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
          local image = help.cropSurface(2.19, gears.surface.load_uncached(beautiful.songpic))
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
