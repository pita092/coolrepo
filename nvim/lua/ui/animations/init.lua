-- ai slop
-- :)
local M = {}
local api = vim.api
M.active_timers = {}
function M.cleanup_timer(id)
  if M.active_timers[id] then
    M.active_timers[id]:stop()
    M.active_timers[id] = nil
  end
end

function M.cleanup_all_timers()
  for id, timer in pairs(M.active_timers) do
    timer:stop()
  end
  M.active_timers = {}
end

function M.animate_window_open(win_id, config)
  if not win_id or not api.nvim_win_is_valid(win_id) then
    return
  end

  local win_config = api.nvim_win_get_config(win_id)

  local options = config or {}
  local frames = options.frames or 10
  local duration = options.duration or 120
  local frame_time = duration / frames

  local final_config = {
    row = options.final_row or win_config.row,
    col = options.final_col or win_config.col,
    width = options.final_width or win_config.width,
    height = options.final_height or win_config.height
  }

  local start_config = {
    row = options.start_row or (final_config.row - 2),
    col = options.start_col or final_config.col,
    width = options.start_width or (final_config.width * 0.5),
    height = options.start_height or final_config.height
  }

  -- Calculate steps
  local row_step = (final_config.row - start_config.row) / frames
  local col_step = (final_config.col - start_config.col) / frames
  local width_step = (final_config.width - start_config.width) / frames
  local height_step = (final_config.height - start_config.height) / frames

  api.nvim_win_set_config(win_id, {
    relative = win_config.relative,
    row = math.floor(start_config.row),
    col = math.floor(start_config.col + (final_config.width - start_config.width) / 2),
    width = math.floor(start_config.width),
    height = math.floor(start_config.height)
  })
  local timer_id = win_id .. "_open"

  M.cleanup_timer(timer_id)

  local frame_count = 0
  M.active_timers[timer_id] = vim.loop.new_timer()
  M.active_timers[timer_id]:start(0, frame_time, vim.schedule_wrap(function()
    if not api.nvim_win_is_valid(win_id) then
      M.cleanup_timer(timer_id)
      return
    end

    frame_count = frame_count + 1

    local current_row = start_config.row + row_step * frame_count
    local current_col = start_config.col + col_step * frame_count
    local current_width = start_config.width + width_step * frame_count
    local current_height = start_config.height + height_step * frame_count

    api.nvim_win_set_config(win_id, {
      relative = win_config.relative,
      row = current_row,
      col = current_col + (final_config.width - current_width) / 2,
      width = math.max(1, math.floor(current_width)),
      height = math.max(1, math.floor(current_height))
    })

    if frame_count >= frames then
      M.cleanup_timer(timer_id)

      api.nvim_win_set_config(win_id, {
        relative = win_config.relative,
        row = final_config.row,
        col = final_config.col,
        width = final_config.width,
        height = final_config.height
      })

      if options.on_complete and type(options.on_complete) == "function" then
        vim.schedule(options.on_complete)
      end
    end
  end))

  return timer_id
end

function M.animate_window_close(win_id, config, close_on_finish)
  if not win_id or not api.nvim_win_is_valid(win_id) then
    return
  end

  local win_config = api.nvim_win_get_config(win_id)

  local current_row = type(win_config.row) == "table" and win_config.row[false] or win_config.row
  local current_col = type(win_config.col) == "table" and win_config.col[false] or win_config.col
  local current_width = win_config.width
  local current_height = win_config.height

  local options = config or {}
  local frames = options.frames or 8
  local duration = options.duration or 100
  local frame_time = duration / frames

  local end_config = {
    row = options.end_row or (current_row - 2),
    col = options.end_col or current_col,
    width = options.end_width or (current_width * 0.2),
    height = options.end_height or (current_height * 0.2)
  }

  local row_step = (end_config.row - current_row) / frames
  local col_step = (end_config.col - current_col) / frames
  local width_step = (end_config.width - current_width) / frames
  local height_step = (end_config.height - current_height) / frames

  local timer_id = win_id .. "_close"

  M.cleanup_timer(timer_id)

  local frame_count = 0
  M.active_timers[timer_id] = vim.loop.new_timer()
  M.active_timers[timer_id]:start(0, frame_time, vim.schedule_wrap(function()
    if not api.nvim_win_is_valid(win_id) then
      M.cleanup_timer(timer_id)
      return
    end

    frame_count = frame_count + 1

    local new_row = current_row + row_step * frame_count
    local new_col = current_col + col_step * frame_count
    local new_width = current_width + width_step * frame_count
    local new_height = current_height + height_step * frame_count

    local col_offset = (current_width - new_width) / 2

    api.nvim_win_set_config(win_id, {
      relative = win_config.relative,
      row = new_row,
      col = new_col + col_offset,
      width = math.max(1, math.floor(new_width)),
      height = math.max(1, math.floor(new_height))
    })

    if frame_count >= frames then
      M.cleanup_timer(timer_id)

      if close_on_finish then
        pcall(api.nvim_win_close, win_id, true)
      end

      if options.on_done then
        options.on_done()
      end

      if options.on_complete and type(options.on_complete) == "function" then
        vim.schedule(options.on_complete)
      end
    end
  end))

  return timer_id
end

function M.animate_win_blend(win_id, start_blend, end_blend, duration_ms, on_done, on_complete)
  if not win_id or not api.nvim_win_is_valid(win_id) then
    return
  end

  local frames = 10
  local frame_time = duration_ms / frames
  local blend_step = (end_blend - start_blend) / frames
  local frame_count = 0

  api.nvim_win_set_option(win_id, 'winblend', start_blend)

  local timer_id = win_id .. "_blend"

  M.cleanup_timer(timer_id)

  M.active_timers[timer_id] = vim.loop.new_timer()
  M.active_timers[timer_id]:start(0, frame_time, vim.schedule_wrap(function()
    if not api.nvim_win_is_valid(win_id) then
      M.cleanup_timer(timer_id)
      return
    end

    frame_count = frame_count + 1

    local current_blend = math.floor(start_blend + blend_step * frame_count)

    api.nvim_win_set_option(win_id, 'winblend', current_blend)

    if frame_count >= frames then
      M.cleanup_timer(timer_id)

      api.nvim_win_set_option(win_id, 'winblend', end_blend)

      if on_done then
        on_done()
      end

      if on_complete and type(on_complete) == "function" then
        vim.schedule(on_complete)
      end
    end
  end))

  return timer_id
end

function M.fancy_window_open(win_id, position_config, blend_config)
  local pos_config = position_config or {}
  local blend = blend_config or {}
  local start_blend = blend.start or 100
  local end_blend = blend.end_or_final or 0
  local blend_duration = blend.duration or 150

  local on_complete = pos_config.on_complete

  pos_config.on_complete = nil

  pcall(api.nvim_win_set_option, win_id, 'winblend', start_blend)

  M.animate_window_open(win_id, pos_config)

  M.animate_win_blend(win_id, start_blend, end_blend, blend_duration, blend.on_done, on_complete)
end

function M.fancy_window_close(win_id, position_config, blend_config)
  local pos_config = position_config or {}
  local blend = blend_config or {}
  local start_blend = blend.start or 0
  local end_blend = blend.end_or_final or 100
  local blend_duration = blend.duration or 100

  local on_complete = pos_config.on_complete

  pos_config.on_complete = nil

  M.animate_win_blend(win_id, start_blend, end_blend, blend_duration)

  local should_close = pos_config.close_window ~= false

  pos_config.on_complete = on_complete

  M.animate_window_close(win_id, pos_config, should_close)
end

return M
