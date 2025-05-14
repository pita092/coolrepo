--stole some stuff from https://github.com/VonHeikemen/fine-cmdline.nvim
--because i suck at doing history stuff and i didnt really know how to execute teh commands properly

local M = {}
local api = vim.api
local buf, win

local state = {
  query = '',
  history = nil,
  idx_hist = 0
}

function _G.create_float()
  buf = api.nvim_create_buf(false, true)
  local width = api.nvim_get_option("columns")
  local height = api.nvim_get_option("lines")
  local win_height = 1
  local win_width = 40
  local row = 3
  local col = math.floor((width - win_width) / 2)
  local opts = {
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    style = 'minimal',
    title = "Commands ",
    title_pos = 'left',
    border = {
      { " ", "MySearchBackground" },
      { " ", "MyFloatBorder" },
      { " ", "MyFloatBorder" },
      { " ", "MySearchBackground" },
      { " ", "MySearchBackground" },
      { " ", "MySearchBackground" },
      { " ", "MySearchBackground" },
      { " ", "MySearchBackground" },
    }
  }
  win = api.nvim_open_win(buf, true, opts)
  api.nvim_win_set_option(win, 'winhl', 'Normal:MySearchBackground,FloatBorder:MyFloatBorder,FloatTitle:MyCmdLineTitle')
  api.nvim_buf_set_name(buf, "UniqueFloatingCmdLineName")
  api.nvim_win_set_option(win, 'winblend', 0)
  api.nvim_buf_set_option(buf, 'buftype', 'prompt')
  api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

  vim.fn.prompt_setprompt(buf, ' ')
  vim.fn.prompt_setcallback(buf, _G.execute_command)

  api.nvim_buf_set_keymap(buf, 'i', '<Tab>', '<C-x><C-v>', { noremap = true, silent = true })
  api.nvim_buf_set_keymap(buf, 'i', '<S-Tab>', '<C-p>', { noremap = true, silent = true })
  api.nvim_buf_set_keymap(buf, 'i', '<Esc>', '<cmd>lua close_floating_cmdline()<CR>', { noremap = true, silent = true })
  api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '<cmd>lua close_floating_cmdline()<CR>', { noremap = true, silent = true })

  -- History navigation keymaps
  api.nvim_buf_set_keymap(buf, 'i', '<Up>', '<cmd>lua up_history()<CR>', { noremap = true, silent = true })
  api.nvim_buf_set_keymap(buf, 'i', '<Down>', '<cmd>lua down_history()<CR>', { noremap = true, silent = true })

  vim.cmd('startinsert!')
  animation.fancy_window_open(win, {
    start_row = 1,
    start_width = 20,
    final_row = row,
    final_width = win_width,
    frames = 10,
    duration = 150,
  })
end

function _G.execute_command(value)
  _G.close_floating_cmdline(true)

  vim.fn.histadd('cmd', value)

  _G.reset_history()

  vim.schedule(function()
    local ok, err = pcall(vim.cmd, value)
    if not ok then
      local idx = err:find(':E')
      if type(idx) == 'number' then
        local msg = err:sub(idx + 1):gsub('\t', '    ')
        vim.notify(msg, vim.log.levels.ERROR)
      else
        vim.notify(err, vim.log.levels.ERROR)
      end
    end
  end)
end

function _G.close_floating_cmdline(immediate)
  if win and api.nvim_win_is_valid(win) then
    if immediate then
      pcall(api.nvim_win_close, win, true)
      pcall(api.nvim_buf_delete, buf, { force = true })
      win = nil
      buf = nil
    else
      animation.fancy_window_close(win, {
        end_row = 1,
        end_width = 5,
        frames = 8,
        duration = 120,
      })
    end
  else
    win = nil
    buf = nil
  end
end

function _G.show_floating_cmdline()
  if win and api.nvim_win_is_valid(win) then
    _G.close_floating_cmdline()
  end
  _G.create_float()
end

function _G.cmd_history()
  if state.history then return end

  local history_string = vim.fn.execute('history cmd')
  local history_list = vim.split(history_string, '\n')

  local results = {}
  for i = #history_list, 3, -1 do
    local item = history_list[i]
    local _, finish = string.find(item, '%d+ +')
    if finish then
      table.insert(results, string.sub(item, finish + 1))
    end
  end

  state.history = results
end

function _G.reset_history()
  state.idx_hist = 0
  state.history = nil
  state.query = ''
end

function _G.replace_line(cmd)
  if not buf or not api.nvim_buf_is_valid(buf) then
    return
  end

  local prompt = vim.fn.prompt_getprompt(buf)
  local prompt_len = #prompt

  vim.api.nvim_buf_set_lines(buf, 0, 1, false, { prompt .. cmd })

  if win and api.nvim_win_is_valid(win) then
    vim.api.nvim_win_set_cursor(win, { 1, prompt_len + #cmd })
  end
end

function _G.up_history()
  if vim.fn.pumvisible() == 1 then return end

  if state.idx_hist == 0 then
    local line = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ""
    local prompt = vim.fn.prompt_getprompt(buf)
    state.query = line:sub(#prompt + 1)
  end

  _G.cmd_history()
  state.idx_hist = state.idx_hist + 1
  local cmd = state.history[state.idx_hist]

  if not cmd then
    state.idx_hist = #state.history
    return
  end

  _G.replace_line(cmd)
end

function _G.down_history()
  if vim.fn.pumvisible() == 1 then return end

  _G.cmd_history()
  state.idx_hist = state.idx_hist - 1

  if state.idx_hist <= 0 then
    state.idx_hist = 0
    _G.replace_line(state.query)
    return
  end

  local cmd = state.history[state.idx_hist]
  if cmd then
    _G.replace_line(cmd)
  end
end

function M.setup()
  api.nvim_set_keymap('n', ':', '<cmd>lua show_floating_cmdline()<CR>', { noremap = true, silent = true })
end

return M
