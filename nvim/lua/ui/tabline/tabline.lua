local M = {}
local utils = require("core.utils")

function _G.QuitPlease()
  vim.cmd("quit")
end

function _G.SavePlease()
  vim.cmd("w")
end

M.title = function(bufnr)
  local file = ' ' .. vim.fn.bufname(bufnr)
  local buftype = vim.fn.getbufvar(bufnr, '&buftype')
  local filetype = vim.fn.getbufvar(bufnr, '&filetype')

  if buftype == 'help' then
    return ' help:' .. vim.fn.fnamemodify(file, ':t:r')
  elseif buftype == 'quickfix' then
    return ' quickfix'
  elseif filetype == 'netrw' then
    return ' Netrw'
  elseif filetype == 'TelescopePrompt' then
    return ' Telescope'
  elseif filetype == 'git' then
    return ' Git'
  elseif buftype == 'terminal' then
    local _, mtch = string.match(file, "term:(.*):(%a+)")
    return mtch ~= nil and mtch or vim.fn.fnamemodify(vim.env.SHELL, ':t')
  elseif file == '' then
    return '[No Name]'
  elseif filetype == '' then
    return '[No Name]'
  else
    return vim.fn.pathshorten(vim.fn.fnamemodify(file, ':p:~:t'))
  end
end

M.modified = function(bufnr)
  return vim.fn.getbufvar(bufnr, '&modified') == 1 and '  ' or '  '
end

M.windowCount = function(index)
  local nwins = vim.fn.tabpagewinnr(index, '$')
  return nwins > 1 and '(' .. nwins .. ') ' or ''
end

_G.newTab = function()
  vim.cmd('tab new')
end




_G.ToggleColorMode = function()
  vim.g.colormode = (vim.g.colormode == "dark" and "light" or "dark")
  vim.g.tabcolormode = (vim.g.tabcolormode == " " and " " or " ")
  require("ui.colorscheme." .. vim.g.colormode).load()
  require("ui.statusline." .. vim.g.barstyle).set_highlights()
  utils.save_color_mode()
end



M.rightButton = function()
  local hl = 'highlight TabLineMinus guifg=#e9edf2 guibg=#ef5a5a'
  vim.cmd(hl)
  return '%#TabLineMinus#%@v:lua.QuitPlease@  %#TabLineFill#'
end
M.rightButton2 = function()
  local hl
  if not vim.g.tabcolormode then
    vim.g.tabcolormode = " "
  end

  if vim.g.colormode == "dark" then
    hl = 'highlight TabLineColor guibg=#0c0e0f guifg=#83a5ba'
  elseif vim.g.colormode == "light" then
    hl = 'highlight TabLineColor guibg=#e9edf2 guifg=#a3c76f'
  end
  vim.cmd(hl)
  return '%#TabLineColor#%@v:lua.ToggleColorMode@ ' .. vim.g.tabcolormode .. '%#TabLineColor#'
end
M.rightButton3 = function()
  local hl
  if vim.g.colormode == "dark" then
    hl = 'highlight TabLinePlus guibg=#0c0e0f guifg=#a3c76f'
  elseif vim.g.colormode == "light" then
    hl = 'highlight TabLinePlus guibg=#e9edf2 guifg=#83a5ba'
  end
  vim.cmd(hl)
  return '%#TabLinePlus#%@v:lua.newTab@  %#TabLineFill#'
end
M.rightButton4 = function()
  local bufnr = vim.fn.bufnr('%')
  local isModified = vim.fn.getbufvar(bufnr, '&modified') == 1
  local fg, bg

  if vim.g.colormode == "dark" then
    fg = isModified and '#e9edf2' or '#353535'
    bg = '#0c0e0f'
  elseif vim.g.colormode == "light" then
    fg = isModified and '#0c0e0f' or '#c3ccd8'
    bg = '#e9edf2'
  end

  vim.cmd(string.format('highlight TabLineSave guifg=%s guibg=%s', fg, bg))

  return '%#TabLineSave#%@v:lua.SavePlease@ 󰆓 %#TabLineFill#'
end





M.closeButton = function(index, isSelected)
  local bufnr = vim.fn.tabpagebuflist(index)[1]
  local isModified = vim.fn.getbufvar(bufnr, '&modified') == 1
  local fg, bg, hl_group

  if vim.g.colormode == "dark" then
    fg = isModified and '#a3c76f' or (isSelected and '#ef5a5a' or '#333333')
    bg = isSelected and '#161616' or '#111111'
  elseif vim.g.colormode == "light" then
    fg = isModified and '#a0c00f' or (isSelected and '#ef2a2a' or '#c3ccd8')
    bg = isSelected and '#e9edf2' or '#dde3ea'
  end

  hl_group = string.format('TabLineClose_%d', index)

  vim.cmd(string.format('highlight %s guifg=%s guibg=%s', hl_group, fg, bg))

  if isModified then
    return string.format('%%#%s# %s%%#TabLine#', hl_group, M.modified(bufnr))
  else
    return string.format('%%#%s#%%%dX%s%%#TabLine#', hl_group, index, M.modified(bufnr))
  end
end


M.cell = function(index)
  local isSelected = vim.fn.tabpagenr() == index
  local buflist = vim.fn.tabpagebuflist(index)
  local winnr = vim.fn.tabpagewinnr(index)
  local bufnr = buflist[winnr]
  local fg, bg, hl_group

  if vim.g.colormode == "dark" then
    fg = isSelected and '#e9edf2' or '#333333'
    bg = isSelected and '#161616' or '#111111'
  elseif vim.g.colormode == "light" then
    fg = isSelected and '#121212' or '#c3ccd8'
    bg = isSelected and '#e9edf2' or '#dde3ea'
  end

  hl_group = isSelected and 'TabLineSel' or 'TabLineNorm'

  vim.cmd(string.format('highlight %s guibg=%s guifg=%s', hl_group, bg, fg))

  return string.format('%%#%s#%%%dT %s%s %s%%T',
    hl_group,
    index,
    M.windowCount(index),
    M.title(bufnr),
    M.closeButton(index, isSelected)
  )
end


M.tabline = function()
  local line = ''
  for i = 1, vim.fn.tabpagenr('$'), 1 do
    line = line .. M.cell(i)
  end
  line = line .. '%#TabLineFill#%='
  line = line .. M.rightButton4() .. M.rightButton3() .. M.rightButton2() .. ' %#111111#' .. M.rightButton()
  if vim.fn.tabpagenr('$') > 1 then
    line = line .. '%#TabLine#%999X'
  end
  return line
end

local setup = function()
  vim.opt.tabline = '%!v:lua.require\'ui.tabline.tabline\'.helpers.tabline()'
end

return {
  helpers = M,
  setup = setup,
}
