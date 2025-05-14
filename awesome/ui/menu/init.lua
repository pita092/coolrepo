beautiful.menu_height    = dpi(30)
beautiful.menu_width     = dpi(200)
beautiful.menu_bg_focus  = beautiful.bg_2
beautiful.menu_fg_focus  = beautiful.blue
beautiful.menu_bg_normal = beautiful.bg_2
beautiful.submenu        = ""
myawesomemenu            = {
  { "hotkeys",     function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
  { "manual",      terminal .. " -e man awesome" },
  { "edit config", editor_cmd .. " " .. awesome.conffile },
  { "restart",     awesome.restart },
}

mymainmenu               = awful.menu({
  items = {
    { "     󰍜", myawesomemenu },
  },
})
mymainmenu.wibox.shape   = help.rrect(dpi(4))
