-- local M = {}
--
-- local min = math.min
-- local sin = math.sin
-- local pi = math.pi
-- local pow = function(x, y) return x ^ y end
--
-- local pi_div_2 = pi / 2
-- local two_pi = 2 * pi
--
-- M.easing = {
--   linear = function(t) return t end,
--   easin = function(t) return t * t end,
--   bounce = function(t)
--     if t < 0.5 then
--       return 4 * t * t
--     else
--       local v = t - 0.75
--       return 1 - v * v * 4
--     end
--   end,
--   sinusoidal = function(t)
--     return sin(t * pi_div_2)
--   end,
--   quadratic = function(t)
--     local v = 1 - t
--     return 1 - v * v
--   end,
--   cubic = function(t)
--     local v = 1 - t
--     return 1 - v * v * v
--   end,
--   elastic = function(t)
--     local p = 0.3
--     return pow(2, -10 * t) * sin((t - p / 4) * two_pi / p) + 1
--   end,
--   exponential = function(t)
--     if t == 1 then return 1 end
--     return 1 - pow(2, -10 * t)
--   end
-- }
--
-- function M.animate(params)
--   local start_value = params.start or 0
--   local target_value = params.target or 1
--   local duration = params.duration or 0.5
--   local interval = params.interval or 0.02
--   local easing = params.easing or M.easing.quadratic
--   local on_update = params.update or function() end
--   local on_complete = params.complete or function() end
--
--   local time_elapsed = 0
--   local current_value = start_value
--   local is_paused = false
--   local timer
--
--   on_update(start_value, 0)
--
--   timer = gears.timer {
--     timeout = interval,
--     autostart = true,
--     callback = function()
--       -- Early return if paused
--       if is_paused then return true end
--
--       time_elapsed = time_elapsed + interval
--       local progress = min(time_elapsed / duration, 1)
--       local eased_progress = easing(progress)
--
--       current_value = start_value + (target_value - start_value) * eased_progress
--       on_update(current_value, progress)
--
--       if progress >= 1 then
--         timer:stop()
--         timer = nil
--         on_complete()
--         return false
--       end
--
--       return true
--     end
--   }
--
--   local controller = {
--     stop = function()
--       if timer then
--         timer:stop()
--         timer = nil
--       end
--     end,
--     pause = function()
--       is_paused = true
--     end,
--     resume = function()
--       is_paused = false
--     end,
--     set_speed = function(speed_multiplier)
--       if timer then
--         timer.timeout = interval / (speed_multiplier or 1)
--       end
--     end,
--     get_value = function()
--       return current_value
--     end
--   }
--
--   return controller
-- end
--
-- function M.slide_y(element, params)
--   params = params or {}
--   params.update = params.update or function(pos)
--     element.y = pos
--   end
--   return M.animate(params)
-- end
--
-- function M.slide(element, params)
--   params = params or {}
--   params.update = params.update or function(pos)
--     element.x = pos
--   end
--   return M.animate(params)
-- end
--
-- function M.progress(params)
--   params = params or {}
--   params.update = params.update or function(value)
--     if params.progress_bar then
--       params.progress_bar:set_value(value)
--     end
--   end
--   return M.animate(params)
-- end
--
-- function M.fade(element, params)
--   params = params or {}
--   params.update = params.update or function(value)
--     element.opacity = value
--   end
--   return M.animate(params)
-- end
--
-- function M.resize(element, params)
--   params = params or {}
--   local start_width = params.start_width or element.width
--   local target_width = params.target_width or element.width
--   local start_height = params.start_height or element.height
--   local target_height = params.target_height or element.height
--
--   params.start = 0
--   params.target = 1
--   params.update = function(progress)
--     local width = start_width + (target_width - start_width) * progress
--     local height = start_height + (target_height - start_height) * progress
--     element.width = width
--     element.height = height
--     if params.on_resize then
--       params.on_resize(width, height, progress)
--     end
--   end
--
--   return M.animate(params)
-- end
--
-- return M


local M = {}

local min = math.min
local sin = math.sin
local pi = math.pi
local pow = function(x, y) return x ^ y end
local pi_div_2 = pi / 2
local two_pi = 2 * pi

M.easing = {
  linear = function(t) return t end,
  easin = function(t) return t * t end,
  bounce = function(t)
    if t < 0.5 then
      return 4 * t * t
    else
      local v = t - 0.75
      return 1 - v * v * 4
    end
  end,
  sinusoidal = function(t)
    return sin(t * pi_div_2)
  end,
  quadratic = function(t)
    local v = 1 - t
    return 1 - v * v
  end,
  cubic = function(t)
    local v = 1 - t
    return 1 - v * v * v
  end,
  elastic = function(t)
    local p = 0.3
    return pow(2, -10 * t) * sin((t - p / 4) * two_pi / p) + 1
  end,
  exponential = function(t)
    if t == 1 then return 1 end
    return 1 - pow(2, -10 * t)
  end
}

-- Main animation function
function M.animate(params)
  local start_value = params.start or 0
  local target_value = params.target or 1
  local duration = params.duration or 0.5
  local interval = params.interval or 0.02
  local easing = params.easing or M.easing.quadratic
  local on_update = params.update or function() end
  local on_complete = params.complete or function() end

  -- Pre-calculate the value difference for optimization
  local value_diff = target_value - start_value

  local time_elapsed = 0
  local current_value = start_value
  local is_paused = false
  local timer

  -- Call initial update
  on_update(start_value, 0)

  timer = gears.timer {
    timeout = interval,
    autostart = true,
    callback = function()
      if is_paused then return true end

      time_elapsed = time_elapsed + interval
      local progress = min(time_elapsed / duration, 1)
      local eased_progress = easing(progress)

      current_value = start_value + value_diff * eased_progress

      on_update(current_value, progress)

      if progress >= 1 then
        timer:stop()
        timer = nil
        on_complete()
        return false
      end

      return true
    end
  }

  local controller = {
    stop = function()
      if timer then
        timer:stop()
        timer = nil
      end
    end,
    pause = function()
      is_paused = true
    end,
    resume = function()
      is_paused = false
    end,
    set_speed = function(speed_multiplier)
      if timer then
        timer.timeout = interval / (speed_multiplier or 1)
      end
    end,
    get_value = function()
      return current_value
    end
  }

  return controller
end

function M.slide_y(element, params)
  params = params or {}
  params.update = params.update or function(pos)
    element.y = pos
  end
  return M.animate(params)
end

function M.slide(element, params)
  params = params or {}
  params.update = params.update or function(pos)
    element.x = pos
  end
  return M.animate(params)
end

function M.progress(params)
  params = params or {}
  params.update = params.update or function(value)
    if params.progress_bar then
      params.progress_bar:set_value(value)
    end
  end
  return M.animate(params)
end

function M.fade(element, params)
  params = params or {}
  params.update = params.update or function(value)
    element.opacity = value
  end
  return M.animate(params)
end

function M.resize(element, params)
  params = params or {}
  local start_width = params.start_width or element.width
  local target_width = params.target_width or element.width
  local start_height = params.start_height or element.height
  local target_height = params.target_height or element.height

  params.start = 0
  params.target = 1
  params.update = function(progress)
    local width = start_width + (target_width - start_width) * progress
    local height = start_height + (target_height - start_height) * progress
    element.width = width
    element.height = height
    if params.on_resize then
      params.on_resize(width, height, progress)
    end
  end
  return M.animate(params)
end

return M
