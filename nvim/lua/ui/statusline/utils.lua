local M = {}

function M.get_file_name()
  local file_name = vim.fn.expand("%:t")
  if file_name == "" then
    return "no-file"
  else
    return file_name
  end
end

function M.get_lsp_client_name()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if next(clients) ~= nil then
    local client_name = clients[1].name or "LSP"
    return client_name, "DiagnosticOk"
  end
  return "No LSP", "DiagnosticError"
end

function M.get_column()
  local col = vim.fn.col(".")
  return col
end

function M.get_row()
  local row = vim.fn.line(".")
  return row
end

function M.get_mode()
  local modes = {
    ['n']  = { '', 'NORMAL', 'StPurple', 'StPurpleDim' },
    ['no'] = { '', 'NORMAL', 'StPurple', 'StPurpleDim' },
    ['v']  = { '󰩬', 'VISUAL', 'StRed', 'StRedDim' },
    ['V']  = { '󰩬', 'VISUAL LINE', 'StRed', 'StRedDim' },
    ['']   = { '󰩬', 'VISUAL BLOCK', 'StRed', 'StRedDim' },
    ['s']  = { '󰩬', 'SELECT', 'StRed', 'StRedDim' },
    ['S']  = { '󰩬', 'SELECT LINE', 'StRed', 'StRedDim' },
    ['i']  = { '󰏫', 'INSERT', 'StBlue', 'StBlueDim' },
    ['ic'] = { '󰏫', 'INSERT', 'StBlue', 'StBlueDim' },
    ['R']  = { '󰛔', 'REPLACE', 'StRed', 'StRedDim' },
    ['Rv'] = { '󰛔', 'REPLACE', 'StRed', 'StRedDim' },
    ['c']  = { '󰘳', 'COMMAND', 'StYellow', 'StYellowDim' },
    ['cv'] = { '󰘳', 'COMMAND', 'StYellow', 'StYellowDim' },
    ['ce'] = { '󰘳', 'COMMAND', 'StYellow', 'StYellowDim' },
    ['r']  = { '󰘳', 'PROMPT', 'StYellow', 'StYellowDim' },
    ['rm'] = { '󰘳', 'MOAR', 'StYellow', 'StYellowDim' },
    ['r?'] = { '󰘳', 'CONFIRM', 'StYellow', 'StYellowDim' },
    ['!']  = { '󰘳', 'SHELL', 'StYellow', 'StYellowDim' },
    ['t']  = { ' ', 'TERMINAL', 'StYellow', 'StYellowDim' },
  }
  local mode = vim.api.nvim_get_mode().mode
  local mode_data = modes[mode] or { '-', 'UNKNOWN', 'StGreen', 'StGreenDim' }
  return mode_data
end

function M.get_git_branch()
  local branch = vim.fn.system("git branch --show-current 2>/dev/null"):gsub("\n", "")
  if branch ~= "" then
    return { '', branch }
  else
    return { '', 'not git' }
  end
end

function M.get_lsp_status()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients > 0 then
    return { ' ', 'LSP', 'StGreen', 'StGreenDim' }
  else
    return { '', 'NO LSP', 'StRed', 'StRedDim' }
  end
end

return M
