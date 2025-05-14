local M = {}
local api = vim.api
local buf, win

local state = {
  query = '',
  history = nil,
  idx_hist = 0
}

function M.create_search_float()
  buf = api.nvim_create_buf(false, true)
  local width = api.nvim_get_option("columns")
  local win_width = 40
  local win_height = 1
  local row = 3
  local col = math.floor((width - win_width) / 2)
  local opts = {
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    style = 'minimal',
    title = "Search ",
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
  api.nvim_buf_set_name(buf, "UniqueFloatingSearchName")
  api.nvim_win_set_option(win, 'winblend', 0)
  api.nvim_buf_set_option(buf, 'buftype', 'prompt')
  api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.fn.prompt_setprompt(buf, ' ')
  vim.fn.prompt_setcallback(buf, M.execute_search)

  api.nvim_buf_set_keymap(buf, 'i', '<Up>', '<cmd>lua require("ui.search.search").up_history()<CR>',
    { noremap = true, silent = true })
  api.nvim_buf_set_keymap(buf, 'i', '<Down>', '<cmd>lua require("ui.search.search").down_history()<CR>',
    { noremap = true, silent = true })

  api.nvim_buf_set_keymap(buf, 'i', '<Esc>', '<cmd>lua require("ui.search.search").close_floating_search()<CR>',
    { noremap = true, silent = true })
  api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '<cmd>lua require("ui.search.search").close_floating_search()<CR>',
    { noremap = true, silent = true })
  vim.cmd('startinsert!')
  animation.fancy_window_open(win, {
    start_row = 1,
    start_width = 20,
    final_row = row,
    final_width = win_width,
    frames = 10,
    duration = 150,
  })
  api.nvim_create_autocmd("TextChangedI", {
    buffer = buf,
    callback = function()
      local line = api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ""
      local query = line:sub(3)
      if #query > 0 then
        pcall(function()
          local escaped_query = vim.fn.escape(query, '\\/.*$^~[]')
          vim.fn.setreg('/', '\\v' .. escaped_query)
          vim.o.hlsearch = true
        end)
      else
        vim.o.hlsearch = false
      end
    end
  })
end

function M.execute_search(value)
  M.close_floating_search(true)
  if #value == 0 then
    return
  end

  vim.fn.histadd('search', value)
  M.reset_history()

  local escaped_value = vim.fn.escape(value, '\\/.*$^~[]')
  vim.fn.setreg('/', '\\v' .. escaped_value)
  vim.o.hlsearch = true

  local current_pos = vim.fn.getcurpos()
  vim.cmd('normal! l')

  local found = vim.fn.search(value)

  if found == 0 then
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd('normal! gg')
    found = vim.fn.search(value)

    if found == 0 then
      vim.fn.setpos('.', current_pos)
      vim.notify("No match found", vim.log.levels.WARN)
    else
      vim.cmd('normal! zz')
      vim.notify("Search wrapped to beginning", vim.log.levels.INFO)
    end
  else
    vim.cmd('normal! zz')
  end
end

function M.close_floating_search(immediate)
  if win and api.nvim_win_is_valid(win) then
    if immediate then
      pcall(api.nvim_win_close, win, true)
      pcall(api.nvim_buf_delete, buf, { force = true })
      win = nil
      buf = nil
    else
      pcall(api.nvim_win_close, win, true)
    end
    vim.o.hlsearch = false
  end
end

function M.show_floating_search()
  if win and api.nvim_win_is_valid(win) then
    M.close_floating_search()
  end
  M.create_search_float()
end

function M.search_history()
  if state.history then return end

  local history_string = vim.fn.execute('history search')
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

function M.reset_history()
  state.idx_hist = 0
  state.history = nil
  state.query = ''
end

function M.replace_line(search_term)
  if not buf or not api.nvim_buf_is_valid(buf) then
    return
  end

  local prompt = vim.fn.prompt_getprompt(buf)
  local prompt_len = #prompt

  vim.api.nvim_buf_set_lines(buf, 0, 1, false, { prompt .. search_term })

  if win and api.nvim_win_is_valid(win) then
    vim.api.nvim_win_set_cursor(win, { 1, prompt_len + #search_term })
  end
end

function M.up_history()
  if vim.fn.pumvisible() == 1 then return end

  if state.idx_hist == 0 then
    local line = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ""
    local prompt = vim.fn.prompt_getprompt(buf)
    state.query = line:sub(#prompt + 1)
  end

  M.search_history()
  state.idx_hist = state.idx_hist + 1
  local term = state.history[state.idx_hist]

  if not term then
    state.idx_hist = #state.history
    return
  end

  M.replace_line(term)
end

function M.down_history()
  if vim.fn.pumvisible() == 1 then return end

  M.search_history()
  state.idx_hist = state.idx_hist - 1

  if state.idx_hist <= 0 then
    state.idx_hist = 0
    M.replace_line(state.query)
    return
  end

  local term = state.history[state.idx_hist]
  if term then
    M.replace_line(term)
  end
end

function M.setup()
  api.nvim_set_keymap('n', '/', '<cmd>lua require("ui.search.search").show_floating_search()<CR>',
    { noremap = true, silent = true })
end

return M
