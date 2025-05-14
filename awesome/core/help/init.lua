local M       = {}

M.rrect       = function(radius)
  radius = radius or dpi(4)
  return function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, radius)
  end
end
--huge thanks to
-- https://github.com/namishh
M.cropSurface = function(ratio, surf)
  local old_w, old_h = gears.surface.get_size(surf)
  local old_ratio = old_w / old_h
  if old_ratio == ratio then return surf end

  local new_h = old_h
  local new_w = old_w
  local offset_h, offset_w = 0, 0
  if (old_ratio < ratio) then
    new_h = math.ceil(old_w * (1 / ratio))
    offset_h = math.ceil((old_h - new_h) / 2)
  else
    new_w = math.ceil(old_h * ratio)
    offset_w = math.ceil((old_w - new_w) / 2)
  end

  local out_surf = cairo.ImageSurface(cairo.Format.ARGB32, new_w, new_h)
  local cr = cairo.Context(out_surf)
  cr:set_source_surface(surf, -offset_w, -offset_h)
  cr.operator = cairo.Operator.SOURCE
  cr:paint()

  return out_surf
end

M.addhover    = function(element, bg, hbg)
  element:connect_signal('mouse::enter', function(self)
    self.bg = hbg
  end)
  element:connect_signal('mouse::leave', function(self)
    self.bg = bg
  end)
end

M.button      = function(cmd, image, color)
  local img = gears.color.recolor_image(
    gears.filesystem.get_configuration_dir() .. "core/theme/icons/google/" .. image .. ".svg", color or beautiful.fg)

  local widget = wibox.widget {
    {
      {
        widget = wibox.widget.imagebox,
        image = img,
        valign = 'center',
        forced_height = 20,
        forced_width = 20,
        resize = true,
      },
      widget = wibox.container.margin,
      margins = 10,
    },
    buttons = {
      awful.button({}, 1, function()
        awful.spawn.with_shell(cmd)
      end)
    },
    widget = wibox.container.background,
    shape = M.rrect(),
    bg = beautiful.bg_2,
  }
  M.addhover(widget, beautiful.bg_2, beautiful.bg .. '99')
  return widget
end

M.colortext   = function(txt, fg)
  if fg == "" then
    fg = beautiful.fg
  end

  return "<span foreground='" .. fg .. "'>" .. txt .. "</span>"
end

return M
