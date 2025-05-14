ruled.client.connect_signal("request::rules", function()
  -- All clients will match this rule.
  ruled.client.append_rule {
    id         = "global",
    rule       = {},
    properties = {
      focus     = awful.client.focus.filter,
      raise     = true,
      screen    = awful.screen.preferred,
      placement = awful.placement.no_overlap + awful.placement.no_offscreen
    }
  }

  -- Floating clients.
  ruled.client.append_rule {
    id         = "floating",
    rule_any   = {
      instance = { "copyq", "pinentry" },
      class    = {
        "Arandr", "Blueman-manager", "Gpick", "Kruler", "Sxiv",
        "Tor Browser", "Wpa_gui", "veromix", "xtightvncviewer",
        "st-awesome"
      },
      name     = {
        "Event Tester",
      },
      role     = {
        "AlarmWindow",
        "ConfigManager",
        "pop-up",
      }
    },
    properties = { floating = true }
  }
  awful.rules.rules = {
    {
      rule = { class = "St" },
      properties = { icon = "/usr/share/icons/hicolor/48x48/apps/st.png" }
    }
  }
  ruled.client.append_rule {
    id         = "titlebars",
    rule_any   = { type = { "normal", "dialog" } },
    properties = { titlebars_enabled = true }
  }
end)
