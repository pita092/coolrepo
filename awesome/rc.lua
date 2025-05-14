require("naughty").connect_signal("request::display_error", function(message, startup)
  require("naughty").notification {
    urgency = "critical",
    title   = "Oops, an error happened" .. (startup and " during startup!" or "!"),
    message = message
  }
end)

tag.connect_signal("request::default_layouts", function()
  require("awful").layout.append_default_layouts({
    require("awful").layout.suit.spiral.dwindle,
    require("awful").layout.suit.floating,
  })
end)
---@diagnostic disable: lowercase-global
pcall(require, "luarocks.loader")
gears = require("gears")
awful = require("awful")
require("awful.autofocus")
wibox         = require("wibox")
cairo         = require("lgi").cairo
beautiful     = require("beautiful")
naughty       = require("naughty")
ruled         = require("ruled")
menubar       = require("menubar")
hotkeys_popup = require("awful.hotkeys_popup")
dpi           = beautiful.xresources.apply_dpi
require("awful.hotkeys_popup.keys")
terminal = "st"
editor = "nvim"
editor_cmd = terminal .. " -e " .. editor
modkey = "Mod1"
config_dir = gears.filesystem.get_configuration_dir()
package.path = config_dir .. "?.lua;" .. package.path
help = require("core.help")
animation = require("core.animation")


local req = {
  "core.rules",
  "core.keys",
  "core.theme",
  "core.startup",
  "ui",
}
for _, i in ipairs(req) do
  require(i)
end
client.connect_signal("mouse::enter", function(c)
  c:activate { context = "mouse_enter", raise = false }
end)

client.connect_signal("manage", function(c)
  c.shape = help.rrect()
end)
awful.spawn("nitrogen --restore")
