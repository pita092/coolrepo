local M = {}


function M.hex_to_rgb(hex)
  hex = hex:gsub("#", "")
  return tonumber("0x" .. hex:sub(1, 2)), tonumber("0x" .. hex:sub(3, 4)), tonumber("0x" .. hex:sub(5, 6))
end

function M.rgb_to_hex(r, g, b)
  return string.format("#%02x%02x%02x", r, g, b)
end

function M.dim_hex_color(hex, percent)
  percent = math.max(0, math.min(100, percent))

  local dim_factor = (100 - percent) / 100

  local r, g, b = M.hex_to_rgb(hex)

  r = math.floor(r * dim_factor)
  g = math.floor(g * dim_factor)
  b = math.floor(b * dim_factor)

  return M.rgb_to_hex(r, g, b)
end

function M.save_color_mode()
  local file = io.open(vim.fn.stdpath('data') .. '/colormode.txt', 'w')
  if file then
    file:write(vim.g.colormode)
    file:close()
  end
end

function M.load_color_mode()
  local file = io.open(vim.fn.stdpath('data') .. '/colormode.txt', 'r')
  if file then
    vim.g.colormode = file:read()
    file:close()
  else
    vim.g.colormode = "dark"
  end
end

return M
