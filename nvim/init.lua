-- -- i started thi project because of this project lol
-- -- https://github.com/sownteedev/TeVim
-- -- i took inspo for the bar :)
-- -- and now that i look at that repo again my tabline is similar
-- -- and kinda stolen form nvchad lol


animation = require("ui.animations")
local req = {
  "core.lazy",
  "core.options",
  "core.keybinds",
  "core.autocmd",
  "core.lsp",
  "ui.terminal",
  "ui.colorscheme",
  "ui.colorit",
  "ui.statusline",
  "ui.tabline",
  "ui.cmd",
  "ui.startscreen",
  "ui.statuscolumn",
  "ui.search",
  "ui.notif",
}
for _, i in pairs(req) do
  require(i)
end

