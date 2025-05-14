local name = wibox.widget {
  widget = wibox.widget.textbox,
  font = beautiful.font,
}

local function update_client_name(c)
  if c then
    name.text = "  " .. c.name or ""
  else
    name.text = ""
  end
end

client.connect_signal("focus", function(c)
  update_client_name(c)
end)

client.connect_signal("unfocus", function(c)
  update_client_name(nil)
end)

update_client_name(client.focus)

local clientName = wibox.widget {
  {
    name,
    widget = wibox.container.background,
    forced_width = 80
  },
  shape = help.rrect(),
  widget = wibox.container.background,
  bg = beautiful.bg,
}

return clientName
