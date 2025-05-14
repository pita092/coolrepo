local M = {}
function M.create_taglist(s)
  local taglist = awful.widget.taglist {
    screen          = s,
    filter          = awful.widget.taglist.filter.all,
    style           = {
      shape = help.rrect()
    },
    buttons         = {
      awful.button({}, 1, function(t)
        t:view_only()
      end),
      awful.button({}, 4, function(t)
        awful.tag.viewprev(t.screen)
      end),
      awful.button({}, 5, function(t)
        awful.tag.viewnext(t.screen)
      end)
    },
    layout          = {
      spacing = 4,
      layout = wibox.layout.fixed.horizontal,
    },
    widget_template = {
      {
        {
          markup = '',
          shape  = help.rrect(),
          widget = wibox.widget.textbox,
        },
        valign        = 'center',
        id            = 'background_role',
        shape         = help.rrect(),
        widget        = wibox.container.background,
        forced_width  = 45,
        forced_height = 14,
      },
      widget = wibox.container.place,
      update_callback = function(self, tag, index, objects)
        local current_tag = awful.screen.focused().selected_tag
        self.active_animations = self.active_animations or {}

        for _, anim in ipairs(self.active_animations) do
          if anim.stop then
            anim:stop()
          end
        end
        self.active_animations = {}


        if current_tag and current_tag.index == index then
          local anim = animation.animate({
            start = 45,
            target = 60,
            duration = 0.3,
            update = function(progress)
              if self:get_children_by_id('background_role')[1].forced_width == 60 then
                return
              end
              self:get_children_by_id('background_role')[1].forced_width = progress
              self:get_children_by_id('background_role')[1].color = beautiful.blue
            end,
          })
          table.insert(self.active_animations, anim)
        else
          self:get_children_by_id('background_role')[1].forced_width = 45
        end
      end

    },
  }

  tag.connect_signal("property::selected", function(t)
    awesome.emit_signal("widget::redraw_needed")
  end)
  return taglist
end

return M
