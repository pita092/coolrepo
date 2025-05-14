local M = require("ui.dashboard")

awesome.connect_signal("quit::dashboard", function()
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

awesome.connect_signal("toggle::dashboard", function()
  local is_visible = M.control_c.visible and M.control_c.y > -M.control_c.height

  if is_visible then
    awesome.emit_signal("quit::dashboard")
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
      target = 386,
      duration = 0.3,
      easing = animation.easing.sinusoidal,
      complete = function()
        M.control_c.animation = nil
      end
    })
  end
end)
