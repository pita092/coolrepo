local dpi      = beautiful.xresources.apply_dpi
local M        = {}

local colors   = require("core.theme.colors")
M.rounding     = dpi(6)

M.wallpaper    = config_dir .. "core/theme/wallpaper/leaves3.jpg"
M.nosongpic    = config_dir .. "/core/them/icons/google/headphones.svg"
M.songpic      = "/tmp/spotify_tmp.png"

M.icon         = "JetBrainsMonoNL 18"
M.font         = "JetBrainsMonoNL 13"
M.font_custom  = "JetBrainsMonoNL "
M.taglist_font = "JetBrainsMonoNL 16"


M.bg_normal   = colors.bg
M.bg_focus    = colors.bg
M.bg_urgent   = colors.bg
M.bg_minimize = colors.bg
M.bg_systray  = colors.bg_1


M.fg_normal    = colors.fg
M.fg_focus     = M.fg
M.fg_urgent    = M.fg
M.fg_minimize  = M.fg

M.useless_gap  = dpi(6)
M.border_width = dpi(0)

-- Colors

M.blue         = colors.blue
M.yellow       = colors.yellow
M.green        = colors.green
M.red          = colors.red
M.invs         = "#00000000"


M.bg   = colors.bg
M.bg_1 = colors.bg_1
M.bg_2 = colors.bg_2
M.bg_3 = colors.bg_3
M.bg_4 = colors.bg_4

M.fg   = colors.fg
M.fg_2 = colors.fg_2
M.fg_3 = colors.fg_3


-- Menu



M.taglist_bg               = M.bg
M.taglist_fg               = M.bg
M.taglist_bg_focus         = M.blue
M.taglist_fg_focus         = M.blue
M.taglist_bg_urgent        = M.red
M.taglist_fg_urgent        = M.red
M.taglist_bg_occupied      = M.bg
M.taglist_fg_occupied      = M.bg
M.taglist_bg_empty         = colors.bg
M.taglist_fg_empty         = colors.fg
M.taglist_disable_icon     = true

M.tasklist_fg_normal       = M.fg
M.tasklist_fg_focus        = M.fg_3
M.tasklist_fg_minimize     = M.fg

M.tasklist_bg_normal       = M.bg
M.tasklist_bg_focus        = M.blue
M.tasklist_bg_minimize     = M.bg_3
M.tasklist_plain_task_name = true

M.notification_spacing     = 15



beautiful.init(M)
