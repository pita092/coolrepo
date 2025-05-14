local M = require("ui.settings")

awesome.connect_signal("quit::settings", function()
  if M.control_c.visible then
    if M.control_c.animation then
      M.control_c.animation:stop()
    end

    M.control_c.animation = animation.slide_y(M.control_c, {
      start = 22,
      target = -M.control_c.height,
      duration = 0.2,
      easing = animation.easing.cubic,
      complete = function()
        M.control_c.visible = false
        M.control_c_grabber:stop()
        M.control_c.animation = nil
      end
    })
  end
end)

awesome.connect_signal("toggle::settings", function()
  local is_visible = M.control_c.visible and M.control_c.y > -M.control_c.height

  if is_visible then
    awesome.emit_signal("quit::settings")
  else
    M.control_c.visible = true
    awful.placement.top_right(
      M.control_c,
      { honor_workarea = true, margins = { top = -M.control_c.height, right = 5 } }
    )
    if M.control_c.animation then
      M.control_c.animation:stop()
    end
    M.control_c.animation = animation.slide_y(M.control_c, {
      start = -M.control_c.height,
      target = dpi(157),
      duration = 0.3,
      easing = animation.easing.sinusoidal,
      complete = function()
        M.control_c.animation = nil
      end
    })
  end
end)

