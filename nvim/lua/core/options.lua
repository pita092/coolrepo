local opt = vim.opt
local o   = vim.o
local g   = vim.g
local s   = vim.schedule


-- opt.colorcolumn = "80"
opt.breakindent = true
opt.smartindent = true
opt.autoindent = true
opt.indentexpr = "nvim_treesitter#indent()"
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.signcolumn = "yes"
opt.updatetime = 50
opt.timeoutlen = 300
opt.splitright = true
opt.splitbelow = true
opt.scrolloff = 10
opt.inccommand = "split"
opt.whichwrap:append("<>[]hl")
opt.hlsearch          = true
opt.incsearch         = true
opt.relativenumber    = true
opt.number            = true
opt.mouse             = "a"
opt.cmdheight         = 1
opt.fillchars         = { eob = " " }
opt.showmode          = false
opt.completeitemalign = "kind,abbr,menu"




--Os
o.omnifunc           = 'v:lua.vim.lsp.omnifunc'
o.showtabline        = 3
o.expandtab          = true
o.termguicolors      = true
o.pumblend           = 0
o.pumheight          = 16
o.winblend           = 0
o.cursorline         = true
o.cursorlineopt      = "number"

--Gs
g.have_nerd_font     = false
g.cursorword_enabled = false
g.netrw_browse_split = 0
g.netrw_banner       = 0
g.netrw_winsize      = 25

--too lazy to switch from vim.cmd
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
