local M = {}
local timer = nil

-- local function is_valid_hex(hex_str)
--   return hex_str:match("^#?[%da-fA-F][%da-fA-F][%da-fA-F][%da-fA-F]?[%da-fA-F]?[%da-fA-F]?$") ~= nil
-- end
local function is_valid_hex(hex_str)
  hex_str = hex_str:gsub("^#", "")
  return hex_str:match("^[%da-fA-F]%da-fA-F]%da-fA-F]$") ~= nil
      or hex_str:match("^[%da-fA-F][%da-fA-F][%da-fA-F][%da-fA-F][%da-fA-F][%da-fA-F]$") ~= nil
end


local function hex_to_rgb(hex_str)
  hex_str = hex_str:gsub("#", "")
  if #hex_str == 3 then
    hex_str = hex_str:gsub(".", function(c) return c .. c end)
  end
  local r = tonumber(hex_str:sub(1, 2), 16)
  local g = tonumber(hex_str:sub(3, 4), 16)
  local b = tonumber(hex_str:sub(5, 6), 16)
  return r, g, b
end

local ns_id = vim.api.nvim_create_namespace('hex_color_ghost')

local function clear_buffer_ghost_text(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
end

local function get_square(hex)
  local r, g, b = hex_to_rgb(hex)
  local hl_group = "GhostColor" .. hex:gsub("#", "")


  --create if is not real
  pcall(vim.api.nvim_set_hl, 0, hl_group, {
    fg = hex,
    bg = "NONE",
  })

  return { "󱓻 ", hl_group }
end

local function debounced_highlight()
  if timer then
    timer:stop()
  end
  timer = vim.loop.new_timer()
  timer:start(100, 0, vim.schedule_wrap(function()
    local ok, err = pcall(function()
      local bufnr = vim.api.nvim_get_current_buf()
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end

      clear_buffer_ghost_text(bufnr)
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

      for lnum, line in ipairs(lines) do
        local matches = {}
        for color_match in line:gmatch("#[%da-fA-F]+") do
          if is_valid_hex(color_match) then
            local s, e = line:find(color_match, 1, true)
            if s then
              table.insert(matches, {
                str = color_match,
                start_pos = s,
              })
            end
          end
        end

        table.sort(matches, function(a, b)
          return a.start_pos < b.start_pos
        end)

        for _, match in ipairs(matches) do
          vim.api.nvim_buf_set_extmark(bufnr, ns_id, lnum - 1, match.start_pos - 1, {
            virt_text = { get_square(match.str) },
            virt_text_pos = "inline",
          })
        end
      end
    end)
    if not ok and err then
      vim.api.nvim_err_writeln("Hex ghost highlighter error: " .. err)
    end
  end))
end

function M.setup(opts)
  opts = opts or {}

  vim.api.nvim_create_augroup("HexColorGhostHighlighter", { clear = true })
  vim.api.nvim_create_autocmd({
    "BufWinEnter",
    "BufWritePost",
    "TextChanged",
    "TextChangedI",
    "TextChangedP"
  }, {
    group = "HexColorGhostHighlighter",
    callback = debounced_highlight,
  })

  vim.api.nvim_create_autocmd("BufUnload", {
    group = "HexColorGhostHighlighter",
    callback = function(opts)
      clear_buffer_ghost_text(opts.buf)
    end
  })

  vim.schedule(function()
    debounced_highlight()
  end)
end

return M
