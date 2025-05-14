local image = wibox.widget {
  widget = wibox.widget.imagebox,
  image = config_dir .. "core/theme/pfp/pfp.svg",
  resize = true,
  forced_height = dpi(160),
  forced_width = dpi(110),
}
image = wibox.container.background(image, beautiful.bg .. "")
image.shape = help.rrect()

return image
