local system_monitor = {}
-- Helper function to read and parse command output
local function read_cmd(cmd)
  local file = io.popen(cmd)
  local output = file:read("*all")
  file:close()
  return output
end

-- Create disk space monitor (innermost)
local disk_progress = wibox.widget {
  value = 0,
  max_value = 1,
  min_value = 0,
  forced_width = 150,
  forced_height = 150,
  paddings = 0,
  border_width = 25,
  color = beautiful.green,
  border_color = beautiful.bg_2,
  widget = wibox.container.radialprogressbar,
  shape = help.rrect(),
}

local ram_progress = wibox.widget {
  {
    disk_progress,
    widget = wibox.container.place
  },
  value = 0,
  max_value = 1,
  min_value = 0,
  forced_width = 200,
  forced_height = 200,
  paddings = 0,
  border_width = 25,
  color = beautiful.blue,
  border_color = beautiful.bg_2,
  widget = wibox.container.radialprogressbar,
  shape = help.rrect(),
}

local cpu_progress = wibox.widget {
  {
    ram_progress,
    halign = "center",
    valign = "center",
    widget = wibox.container.place
  },
  max_value = 1,
  min_value = 0,
  forced_height = 250,
  forced_width = 250,
  border_width = 25,
  color = beautiful.red,
  border_color = beautiful.bg_2,
  widget = wibox.container.radialprogressbar
}

local combined_widget = wibox.widget {
  {
    cpu_progress,
    halign = "center",
    valign = "center",
    widget = wibox.container.place
  },
  widget = wibox.container.background,
  bg = beautiful.bg_1,
  shape = help.rrect(),
  forced_width = 355,
  forced_height = 400,
}

local function update_disk()
  local cmd = "df -h / | tail -1 | awk '{print $5}'"
  local disk_usage_str = read_cmd(cmd):match("(%d+)%%")
  local disk_usage = tonumber(disk_usage_str) or 0

  disk_progress.value = disk_usage / 100
end

local function update_ram()
  local total, used, free, shared, buff_cache, available = 0, 0, 0, 0, 0, 0
  for line in read_cmd("free -m"):gmatch("[^\r\n]+") do
    if line:match("^Mem:") then
      total, used, free, shared, buff_cache, available = line:match(
        "^Mem:%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
      break
    end
  end
  local ram_usage = math.floor((total - available) / total * 100)
  ram_progress.value = ram_usage / 100
end

local function update_cpu()
  local cpu_usage = tonumber(read_cmd("top -bn1 | grep 'Cpu(s)' | awk '{print $2}'")) or 0
  cpu_progress.value = cpu_usage / 100
end

gears.timer {
  timeout   = 15,
  call_now  = true,
  autostart = true,
  callback  = function()
    update_disk()
    update_ram()
    update_cpu()
  end
}

return {
  widget = combined_widget,
  cpu = cpu_progress,
  ram = ram_progress,
  disk = disk_progress
}
