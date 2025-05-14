local M = {}


M.setup = function()
  vim.cmd [[
  :set statuscolumn=%s%C%3l
  ]]
end

return M
