function create_centered_float_terminal()
  local width = vim.api.nvim_get_option("columns")
  local height = vim.api.nvim_get_option("lines")
  local win_width = math.floor(width * 0.7)
  local win_height = math.floor(height * 0.7)
  local row = math.floor((height - win_height) / 2)
  local col = math.floor((width - win_width) / 2)
  local buf = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_set_hl(0, 'MyFloatBorder', {
    fg = '#83a5ba',
    bg = "NONE",
    bold = true
  })
  vim.api.nvim_set_hl(0, 'MyTerminalBackground', {
    bg = '#121212'
  })
  vim.api.nvim_set_hl(0, 'MyFloatTitle', {
    fg = '#83a5ba',
    bg = "#121212",
    bold = true
  })

  local opts = {
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row - 3,
    col = col,
    style = "minimal",
    title = " Terminal ",
    title_pos = "left",
    border = {
      { " ", "MyFloatBorder" },
      { " ", "MyFloatBorder" },
      { " ", "MyFloatBorder" },
      { " ", "MyFloatBorder" },
      { " ", "MyFloatBorder" },
      { " ", "MyFloatBorder" },
      { " ", "MyFloatBorder" },
      { " ", "MyFloatBorder" },
    }
  }

  local win = vim.api.nvim_open_win(buf, true, opts)

  vim.api.nvim_win_set_option(win, 'winhl',
    'FloatBorder:MyFloatBorder,FloatTitle:MyFloatTitle,Normal:MyTerminalBackground')
  vim.api.nvim_win_set_option(win, 'winblend', 100) -- Start fully transparent for animation

  vim.b[buf].float_term_win = win

  local term_chan = vim.fn.termopen(vim.o.shell)

  vim.b[buf].term_chan = term_chan

  vim.api.nvim_buf_set_keymap(buf, 't', '<ESC>', '<C-\\><C-n>:lua close_float_terminal()<CR>',
    { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, 'n', '<ESC>', ':lua close_float_terminal()<CR>', { noremap = true, silent = true })

  _G.close_float_terminal = function()
    if win and vim.api.nvim_win_is_valid(win) then
      animation.fancy_window_close(win, {
        end_row = row - 8,
        end_height = win_height / 3,
        end_width = win_width / 2,
        frames = 8,
        duration = 100,
        close_window = true,
        on_complete = function()
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      })
    end
  end

  animation.fancy_window_open(win, {
    start_row = row + win_height / 2,
    start_height = 5,
    start_width = win_width / 2,
    final_row = row - 3,
    final_height = win_height,
    final_width = win_width,
    frames = 12,
    duration = 180,
    on_done = function()
      vim.api.nvim_set_current_win(win)

      vim.api.nvim_set_current_buf(buf)

      vim.cmd('startinsert')
      vim.cmd('redraw')
    end
  }, {
    start = 100,
    end_or_final = 0,
    duration = 200
  })

  return buf, win
end

function _G.toggle_float_terminal()
  local existing_term_bufs = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == 'terminal' then
      table.insert(existing_term_bufs, buf)
    end
  end

  if #existing_term_bufs > 0 then
    for _, buf in ipairs(existing_term_bufs) do
      local win_id = vim.b[buf].float_term_win
      if win_id and vim.api.nvim_win_is_valid(win_id) then
        _G.close_float_terminal()
        return
      end
    end
    for _, buf in ipairs(existing_term_bufs) do
      vim.api.nvim_buf_delete(buf, { force = true })
    end
    create_centered_float_terminal()
  else
    create_centered_float_terminal()
  end
end

vim.keymap.set('n', 'nt', toggle_float_terminal, { desc = 'Toggle custom terminal' })
