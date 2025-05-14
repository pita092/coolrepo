local map = vim.keymap.set

map('n', '<c-h>', '<c-w><c-h>', { desc = 'move focus to the left window' })
map('n', '<c-l>', '<c-w><c-l>', { desc = 'move focus to the right window' })
map('n', '<c-j>', '<c-w><c-j>', { desc = 'move focus to the lower window' })
map('n', '<c-k>', '<c-w><c-k>', { desc = 'move focus to the upper window' })
map('t', '<c-h>', '<c-w><c-h>', { desc = 'move focus to the left window' })
map('t', '<c-l>', '<c-w><c-l>', { desc = 'move focus to the right window' })
map('t', '<c-j>', '<c-w><c-j>', { desc = 'move focus to the lower window' })
map('t', '<c-k>', '<c-w><c-k>', { desc = 'move focus to the upper window' })
map('t', '<esc>', [[<c-\><c-n>]], { desc = 'leave terminal mode' })
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '>-2<CR>gv=gv", { silent = true })
map("n", "<C-d>", "zz")
map('v', 'gy', '"+y', { noremap = true, silent = true })
map('n', 'gy', '"+yy', { noremap = true, silent = true })
map("n", "<leader>tr", "<cmd>let netrw_liststyle=3 | Lex!<CR>", { silent = true })
map("n", "<leader>ex", "<cmd>let netrw_liststyle=0 | Ex<CR>", { silent = true })
map("n", "<Esc>", "<cmd>noh<CR>", { desc = "General Clear highlights" })
map("n", "<leader>ds", vim.diagnostic.setloclist)
vim.api.nvim_set_keymap('i', '<CR>', 'pumvisible() ? "\\<C-y>" : "\\<CR>"', { expr = true, noremap = true })


vim.api.nvim_create_autocmd("FileType", {
  pattern = "netrw",
  callback = function()
    vim.api.nvim_buf_set_keymap(0, 'n', '<C-q>', '<CMD>q!<CR>', { noremap = true, silent = true })
  end
})
