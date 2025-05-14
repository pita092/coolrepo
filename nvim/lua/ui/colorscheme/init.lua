local utils = require("core.utils")

utils.load_color_mode()
require("ui.colorscheme." .. vim.g.colormode).load()
