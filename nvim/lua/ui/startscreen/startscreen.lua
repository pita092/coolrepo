--[[
i took it from
https://github.com/Bekaboo/nvim
--]]


-- Global variables to store the buffer and window
local intro_buf, intro_win

---Check if the intro message is disabled by user
---@return boolean
local function intro_disabled()
  return vim.go.shortmess:find('I', 1, true) ~= nil
end

---@return boolean
local function should_show_intro()
  return vim.fn.argc() == 0 and not intro_disabled()
end

local function create_intro_message()
  local logo = 'pita'

  local lines = {
    { text = string.format('%s', logo), hl = 'pitaBlue' },
    { text = string.format('"neovim"'), hl = 'NonText' },
    { text = string.format(''), hl = 'NonText' },
    { text = string.format('   '), hl = 'NonText' },

  }

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].swapfile = false

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.tbl_map(function(line) return line.text end, lines))

  local ns = vim.api.nvim_create_namespace('NvimIntro')
  for i, line in ipairs(lines) do
    vim.api.nvim_buf_add_highlight(buf, ns, line.hl, i - 1, 0, -1)
  end

  return buf
end

local function display_intro(buf)
  local width = 0
  local height = vim.api.nvim_buf_line_count(buf)
  for i = 0, height - 1 do
    local line_width = vim.fn.strdisplaywidth(vim.api.nvim_buf_get_lines(buf, i, i + 1, false)[1])
    width = math.max(width, line_width)
  end

  local win_config = {
    relative = 'editor',
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2) - 1,
    style = 'minimal',
    focusable = false,
  }

  local win = vim.api.nvim_open_win(buf, false, win_config)
  vim.wo[win].winhl = 'Normal:Normal'

  return win
end

local function clear_intro()
  if intro_win and vim.api.nvim_win_is_valid(intro_win) then
    vim.api.nvim_win_close(intro_win, true)
  end
  if intro_buf and vim.api.nvim_buf_is_valid(intro_buf) then
    vim.api.nvim_buf_delete(intro_buf, { force = true })
  end
  intro_buf, intro_win = nil, nil
end

if should_show_intro() then
  intro_buf = create_intro_message()
end

local group = vim.api.nvim_create_augroup('NvimIntro', { clear = true })

vim.api.nvim_create_autocmd('VimEnter', {
  group = group,
  callback = function()
    if should_show_intro() then
      if not intro_buf or not vim.api.nvim_buf_is_valid(intro_buf) then
        intro_buf = create_intro_message()
      end
      intro_win = display_intro(intro_buf)
      -- Disable default intro message
      vim.opt.shortmess:append('I')
    else
      clear_intro()
    end
  end,
})

vim.api.nvim_create_autocmd({
  'BufNewFile', 'BufReadPre', 'FileReadPre', 'StdinReadPre',
  'VimResized', 'TermOpen', 'CursorMoved', 'InsertEnter',
}, {
  group = group,
  callback = function()
    clear_intro()
    return true
  end,
})

vim.api.nvim_create_autocmd('OptionSet', {
  group = group,
  pattern = 'shortmess',
  callback = function()
    if intro_disabled() then
      clear_intro()
    end
  end,
})
