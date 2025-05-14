local NotificationSystem = {}

NotificationSystem.config = {
  max_width = 60,
  min_width = 20,
  padding = 2,
  timeout = { info = 3000, warn = 5000, error = 0 },
  icons = { info = "I", warn = "W", error = "X" },
  position = "bottom_right",
  border = "none",
  max_notifications = 6,
  capture_cmd_output = true,
  capture_messages = true,
  capture_error_messages = true,
}


NotificationSystem.active = {}
NotificationSystem.queue = {}
NotificationSystem.next_id = 1

function NotificationSystem.calculate_position(width, height)
  local win_height = vim.api.nvim_get_option("lines")
  local win_width = vim.api.nvim_get_option("columns")
  local pos = NotificationSystem.config.position
  local row = pos:match("top") and 1 or (win_height - height)
  local col = pos:match("right") and (win_width - width) or 2
  return row, col
end

function NotificationSystem.get_highlights(level)
  local highlights = {
    info = {
      border = "pitaBlue",
      title = "pitaBlue",
      body = "pitaBlue",
    },
    warn = {
      border = "pitaYellow",
      title = "pitaYellow",
      body = "pitaYellow",
    },
    error = {
      border = "pitaRed",
      title = "pitaRed",
      body = "pitaRed",
    },
  }


  return highlights[level] or highlights.info
end

function NotificationSystem.format_content(message, level, title)
  local icon = NotificationSystem.config.icons[level] or ""
  local pad = string.rep(" ", NotificationSystem.config.padding)
  local content = {}
  local width = NotificationSystem.config.max_width - (NotificationSystem.config.padding * 2)

  table.insert(content, pad .. icon)

  for line in message:gmatch("[^\n]+") do
    if #line > width then
      local current_line = ""
      for word in line:gmatch("%S+") do
        if #current_line + #word + 1 > width then
          table.insert(content, pad .. current_line)
          current_line = word
        else
          current_line = current_line == "" and word or (current_line .. " " .. word)
        end
      end
      if current_line ~= "" then
        table.insert(content, pad .. current_line)
      end
    else
      table.insert(content, pad .. line)
    end
  end

  table.insert(content, "")
  return content
end

function NotificationSystem.process_queue()
  if #NotificationSystem.active >= NotificationSystem.config.max_notifications then return end

  if #NotificationSystem.queue > 0 then
    local next_notif = table.remove(NotificationSystem.queue, 1)
    NotificationSystem.show(next_notif.message, next_notif.level, next_notif.opts)
  end
end

function NotificationSystem.close(id)
  local notification = NotificationSystem.active[id]
  if not notification then return end

  if vim.api.nvim_win_is_valid(notification.win) then
    vim.api.nvim_win_close(notification.win, true)
  end

  if vim.api.nvim_buf_is_valid(notification.buf) then
    vim.api.nvim_buf_delete(notification.buf, { force = true })
  end

  NotificationSystem.active[id] = nil
  vim.defer_fn(function() NotificationSystem.process_queue() end, 100)
end

function NotificationSystem.add_dismiss_keymap(buf, id)
  local cmd_fmt = ":lua require('ui.notif.notif').close(%d)<CR>"
  local opts = { noremap = true, silent = true }
  vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', string.format(cmd_fmt, id), opts)
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', string.format(cmd_fmt, id), opts)
end

function NotificationSystem.update_positions()
  local notifications = {}
  for id, notif in pairs(NotificationSystem.active) do
    table.insert(notifications, { id = id, notif = notif })
  end

  table.sort(notifications, function(a, b) return a.id < b.id end)

  local pos = NotificationSystem.config.position
  local offset = 0

  for _, item in ipairs(notifications) do
    local notif = item.notif
    if vim.api.nvim_win_is_valid(notif.win) then
      local win_height = vim.api.nvim_win_get_height(notif.win)
      local win_width = vim.api.nvim_win_get_width(notif.win)
      local row, col = NotificationSystem.calculate_position(win_width, win_height)

      if pos:match("top") then
        row = row + offset
      else
        row = row - offset
      end

      vim.api.nvim_win_set_config(notif.win, {
        relative = "editor",
        row = row,
        col = col,
        width = win_width,
        height = win_height
      })

      offset = offset + win_height + 1
    end
  end
end

function NotificationSystem.get_next_id()
  local id = NotificationSystem.next_id
  NotificationSystem.next_id = NotificationSystem.next_id + 1
  return id
end

function NotificationSystem.show(message, level, opts)
  opts = opts or {}
  level = level or "info"

  if type(level) == "number" then
    local levels = { [0] = "error", [1] = "warn", [2] = "info", [3] = "info", [4] = "info" }
    level = levels[level] or "info"
  end

  if #vim.tbl_keys(NotificationSystem.active) >= NotificationSystem.config.max_notifications then
    table.insert(NotificationSystem.queue, {
      message = message,
      level = level,
      opts = opts
    })
    return
  end

  local content = NotificationSystem.format_content(message, level, opts.title)
  local height = #content
  local width = NotificationSystem.config.max_width
  local row, col = NotificationSystem.calculate_position(width, height)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

  local win = vim.api.nvim_open_win(buf, false, {
    style = "minimal",
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    border = "none",
    focusable = false,
  })

  local highlights = NotificationSystem.get_highlights(level)
  vim.api.nvim_win_set_option(win, "winhighlight", "Normal:" .. highlights.body .. ",FloatBorder:" .. highlights.border)

  local id = NotificationSystem.get_next_id()
  NotificationSystem.active[id] = {
    buf = buf,
    win = win,
    level = level,
    created_at = vim.loop.now(),
  }

  NotificationSystem.add_dismiss_keymap(buf, id)
  NotificationSystem.update_positions()

  local timeout = opts.timeout or NotificationSystem.config.timeout[level] or 3000
  if timeout > 0 then
    vim.defer_fn(function() NotificationSystem.close(id) end, timeout)
  end

  return id
end

function NotificationSystem.capture_echo(cmd_output, title)
  if not cmd_output or cmd_output == "" then return end
  NotificationSystem.show(cmd_output, "info", { title = title or "Command Output" })
end

function NotificationSystem.setup_command_capture()
  if NotificationSystem.config.capture_cmd_output then
    vim.cmd([[
      function! s:ExecuteAndNotify(cmd) abort
        let l:verbose_save = &verbose
        let l:shellredir_save = &shellredir
        set verbose=0
        set shellredir=>%s
        redir => l:output
        silent! execute a:cmd
        redir END
        let &verbose = l:verbose_save
        let &shellredir = l:shellredir_save
        if !empty(l:output)
          call luaeval("require('ui.notif.notif').capture_echo(_A[1], _A[2])", [l:output, a:cmd])
        endif
        return l:output
      endfunction
      command! -nargs=+ -complete=command Echo call s:ExecuteAndNotify(<q-args>)
      command! -nargs=+ -complete=command Echom call s:ExecuteAndNotify("echom " . <q-args>)
    ]])
  end

  if NotificationSystem.config.capture_error_messages then
    vim.cmd([[
      function! s:CaptureErr(msg, level) abort
        call luaeval("require('ui.notif.notif').show(_A[1], 'error', {title = 'Error'})", [a:msg])
      endfunction
      autocmd VimEnter * lua vim.on_lerror = function(err) vim.notify(err, 'error', {title = 'Lua Error'}) end
      autocmd BufEnter * try | call s:ErrorHook() | catch | call s:CaptureErr(v:exception, 'error') | endtry
      function! s:ErrorHook()
      endfunction
    ]])
  end

  if NotificationSystem.config.capture_messages then
    vim.cmd([[
      let g:last_message_idx = 0
      function! s:CheckNewMessages()
        let l:msgs = execute('messages')
        let l:msg_lines = split(l:msgs, "\n")
        let l:new_count = len(l:msg_lines) - g:last_message_idx
        if l:new_count > 0
          let l:new_messages = l:msg_lines[g:last_message_idx : ]
          let g:last_message_idx = len(l:msg_lines)
          if len(l:new_messages) > 0 && join(l:new_messages, '') != ''
            call luaeval("require('ui.notif.notif').show(_A[1], 'info', {title = 'Messages'})",
                  \ [join(l:new_messages, "\n")])
          endif
        endif
      endfunction
      autocmd CursorHold,CursorHoldI * call s:CheckNewMessages()
    ]])
  end
end

function NotificationSystem.setup(user_config)
  if user_config then
    for k, v in pairs(user_config) do
      if type(v) == "table" and type(NotificationSystem.config[k]) == "table" then
        for k2, v2 in pairs(v) do
          NotificationSystem.config[k][k2] = v2
        end
      else
        NotificationSystem.config[k] = v
      end
    end
  end

  vim.notify = function(msg, level, opts)
    return NotificationSystem.show(msg, level, opts)
  end

  NotificationSystem.setup_command_capture()

  vim.cmd([[
    augroup NotificationSystem
      autocmd!
      autocmd VimResized * lua require('ui.notif.notif').update_positions()
    augroup END
  ]])
end

return NotificationSystem
