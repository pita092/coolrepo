local M = {}
local dimhex = require("core.utils")
local utils = require("ui.statusline.utils")
local colors

function M.set_highlights()
  if vim.g.colormode == "dark" then
    colors = {
      green = "#a3c76f",
      blue = "#83a5ba",
      purple = "#ab89b2",
      red = "#ef5a5a",
      yellow = "#e8b563",
      bg = "#0c0e0f",
      text = "#abb2bf",
      sep_bg = "#0c0e0f",
      sep_fg = "#e9e4e4"
    }
  elseif vim.g.colormode == "light" then
    colors = {
      green = "#a0c00f",
      blue = "#49a5ba",
      purple = "#ab49b2",
      red = "#ef2a2a",
      yellow = "#e0b022",
      bg = "#e9edf2",
      text = "#0c0e0f",
      sep_bg = "#e9edf2",
      sep_fg = "#0c0e0f"
    }
  end

  local highlights = {
    StGreen     = { bg = colors.green, fg = colors.bg },
    StGreenDim  = { bg = dimhex.dim_hex_color(colors.green, 80), fg = colors.green },
    StBlue      = { bg = colors.blue, fg = colors.bg },
    StBlueDim   = { bg = dimhex.dim_hex_color(colors.blue, 80), fg = colors.blue },
    StPurple    = { bg = colors.purple, fg = colors.bg },
    StPurpleDim = { bg = dimhex.dim_hex_color(colors.purple, 80), fg = colors.purple },
    StRed       = { bg = colors.red, fg = colors.bg },
    StRedDim    = { bg = dimhex.dim_hex_color(colors.red, 80), fg = colors.red },
    StYellow    = { bg = colors.yellow, fg = colors.bg },
    StYellowDim = { bg = dimhex.dim_hex_color(colors.yellow, 80), fg = colors.yellow },
    StText      = { bg = colors.bg, fg = colors.text },
    StSep       = { bg = colors.sep_bg, fg = colors.sep_fg },
  }
  for group, colors in pairs(highlights) do
    vim.cmd(string.format(
      "hi %s guibg=%s guifg=%s",
      group,
      colors.bg,
      colors.fg
    ))
  end
end

function StatusLine()
  local mode_data = utils.get_mode()
  local mode_icon = mode_data[1]
  local mode_name = mode_data[2]
  local mode_color = mode_data[3]
  local mode_color_dim = mode_data[4]

  local components = {
    '%#' .. mode_color .. '#',
    ' ', mode_icon, ' ',
    '%#' .. mode_color_dim .. '#',
    ' ', mode_name, ' ',
    '%#StText#',
    ' ',
  }

  local branch_data = utils.get_git_branch()
  table.insert(components, '%#StBlue#')
  table.insert(components, ' ' .. branch_data[1] .. ' ')
  table.insert(components, '%#StBlueDim#')
  table.insert(components, ' ' .. branch_data[2] .. ' ')
  table.insert(components, '%#StText#')
  table.insert(components, ' ')

  local lsp_data = utils.get_lsp_status()
  table.insert(components, '%#' .. lsp_data[3] .. '#')
  table.insert(components, ' ' .. lsp_data[1] .. ' ')
  table.insert(components, '%#' .. lsp_data[4] .. '#')
  table.insert(components, ' ' .. lsp_data[2] .. ' ')
  table.insert(components, '%#StText#')

  return table.concat(components)
end

M.set_highlights()


function M.init(x)
  local pos = x or "bottom"
  if pos == "top" then
    vim.opt.ls = 0
    vim.opt.winbar = '%!v:lua.StatusLine()'
  elseif pos == "bottom" then
    vim.opt.ls = 3
    vim.opt.statusline = '%!v:lua.StatusLine()'
  else
    error("chose 'top' or 'bottom'", 2)
  end
end

return M
