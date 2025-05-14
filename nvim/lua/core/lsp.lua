local rename = function()
  local api = vim.api
  local var = vim.fn.expand "<cword>"
  local buf = api.nvim_create_buf(false, true)
  local opts = {
    height = 1,
    style = "minimal",
    border = {
      { " ", "MySearchBackground" },
      { " ", "MyFloatBorder" },
      { " ", "MyFloatBorder" },
      { " ", "MySearchBackground" },
      { " ", "MySearchBackground" },
      { " ", "MySearchBackground" },
      { " ", "MySearchBackground" },
      { " ", "MySearchBackground" },
    }
    ,
    row = 1,
    col = 1
  }

  opts.relative, opts.width = "cursor", #var + 15
  opts.title, opts.title_pos = { { "rename ", "MyCmdLineTitle" } }, "left"

  local win = api.nvim_open_win(buf, true, opts)
  vim.wo[win].winhl = "Normal:CursorLine,FloatBorder:CursorLine"
  api.nvim_set_current_win(win)

  api.nvim_buf_set_lines(buf, 0, -1, true, { " " .. var })
  vim.bo[buf].buftype = "prompt"
  vim.fn.prompt_setprompt(buf, "")
  vim.api.nvim_input "A"

  vim.keymap.set({ "i", "n" }, "<Esc>", "<cmd>q!<CR>", { buffer = buf })

  vim.fn.prompt_setcallback(buf, function(text)
    local newName = vim.trim(text)
    api.nvim_buf_delete(buf, { force = true })

    if #newName > 0 and newName ~= var then
      local params = vim.lsp.util.make_position_params()
      params.newName = newName
      vim.lsp.buf_request(0, "textDocument/rename", params)
    end
  end)
end



vim.lsp.config["lua-language-server"] = {
  cmd = { "lua-language-server" },
  root_markers = { ".luarc.json" },
  filetypes = { "lua" },
}
vim.lsp.config["clangd"] = {
  cmd = { "clangd" },
  filetypes = { "c", "c++" },
}

vim.lsp.enable({ 'lua-language-server' })
vim.lsp.enable({ 'clangd' })
vim.cmd [[set completeopt+=noselect]]
vim.cmd [[inoremap <expr> <c-j> ("\<C-n>")
inoremap <expr> <c-k> ("\<C-p>")]]



vim.o.completeopt = "menuone,noinsert,popup,fuzzy"




local icons = {
  Class = " ",
  Color = " ",
  Constant = " ",
  Constructor = " ",
  Enum = " ",
  EnumMember = " ",
  Field = "󰄶 ",
  File = " ",
  Folder = " ",
  Function = " ",
  Interface = "󰜰",
  Keyword = "󰌆 ",
  Method = "ƒ ",
  Module = "󰏗 ",
  Property = " ",
  Snippet = "󰘍 ",
  Struct = " ",
  Text = " ",
  Unit = " ",
  Value = "󰎠 ",
  Variable = " ",
}

local kinds = vim.lsp.protocol.CompletionItemKind
for i, kind in ipairs(kinds) do
  kinds[i] = icons[kind]
end


vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
  callback = function(event)
    print("lst started")
    local client = assert(vim.lsp.get_client_by_id(event.data.client_id))
    client.server_capabilities.completionProvider.triggerCharacters = vim.split("qwertyuiopasdfghjklzxcvbnm.:\"';< ", "")
    vim.lsp.completion.enable(true, client.id, event.buf, {
      autotrigger = true,
      convert = function(item)
        local kind_to_hl = {
          Function = 'pitaPurple',
          Variable = 'pitaGreen',
          Class = 'pitaBlue',
          Field = 'pitaRed',
          Enum = "pitaYellow"
        }
        local kind_names = {
          [vim.lsp.protocol.CompletionItemKind.Text] = 'Text',
          [vim.lsp.protocol.CompletionItemKind.Method] = 'Method',
          [vim.lsp.protocol.CompletionItemKind.Function] = 'Function',
          [vim.lsp.protocol.CompletionItemKind.Constructor] = 'Constructor',
          [vim.lsp.protocol.CompletionItemKind.Field] = 'Field',
          [vim.lsp.protocol.CompletionItemKind.Variable] = 'Variable',
          [vim.lsp.protocol.CompletionItemKind.Class] = 'Class',
          [vim.lsp.protocol.CompletionItemKind.Interface] = 'Interface',
          [vim.lsp.protocol.CompletionItemKind.Module] = 'Module',
          [vim.lsp.protocol.CompletionItemKind.Property] = 'Property',
          [vim.lsp.protocol.CompletionItemKind.Unit] = 'Unit',
          [vim.lsp.protocol.CompletionItemKind.Value] = 'Value',
          [vim.lsp.protocol.CompletionItemKind.Enum] = 'Enum',
          [vim.lsp.protocol.CompletionItemKind.Keyword] = 'Keyword',
          [vim.lsp.protocol.CompletionItemKind.Snippet] = 'Snippet',
          [vim.lsp.protocol.CompletionItemKind.Color] = 'Color',
          [vim.lsp.protocol.CompletionItemKind.File] = 'File',
          [vim.lsp.protocol.CompletionItemKind.Reference] = 'Reference',
          [vim.lsp.protocol.CompletionItemKind.Folder] = 'Folder',
          [vim.lsp.protocol.CompletionItemKind.EnumMember] = 'EnumMember',
          [vim.lsp.protocol.CompletionItemKind.Constant] = 'Constant',
          [vim.lsp.protocol.CompletionItemKind.Struct] = 'Struct',
          [vim.lsp.protocol.CompletionItemKind.Event] = 'Event',
          [vim.lsp.protocol.CompletionItemKind.Operator] = 'Operator',
          [vim.lsp.protocol.CompletionItemKind.TypeParameter] = 'TypeParameter',
        }
        local hl_group = kind_to_hl[kind_names[item.kind] or 'Unknown'] or 'pitaBlue'
        return {
          abbr = item.label,
          abbr_hlgroup = hl_group,
          kind_hlgroup = hl_group,
        }
      end
    })
    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
    end
    map("<leader>gd", vim.lsp.buf.definition, "defs")
    map("K", vim.lsp.buf.hover, "Hover")
    map("<leader>ca", vim.lsp.buf.code_action, "code actions")
    map("<leader>rn", rename, "rename")
    map("gr", vim.lsp.buf.references, "Goto References ")
    map("gd", vim.lsp.buf.definition, "Goto Definition")
    map("<leader>bf", vim.lsp.buf.format, "Format Buffer")
    map("gi", vim.lsp.buf.implementation, "Goto Implementation")
    map("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
    map("<leader>w", vim.lsp.buf.rename, "Rename")
    map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
    map("gD", vim.lsp.buf.declaration, "Goto Declaration")

    local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })

    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      buffer = event.buf,
      group = highlight_augroup,
      callback = vim.lsp.buf.clear_references,
    })

    vim.api.nvim_create_autocmd("LspDetach", {
      group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
      callback = function(event2)
        vim.lsp.buf.clear_references()
        vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = event2.buf })
      end,
    })
  end
})

vim.diagnostic.config({
  virtual_lines = {
    format = function(diagnostic)
      local icon = ""
      return string.format("%s %s: %s [%s]", icon, diagnostic.source, diagnostic.message, diagnostic.code)
    end,
  },
  underline = true,
  update_in_insert = false,
  severity_sort = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '',
      [vim.diagnostic.severity.WARN] = '',
      [vim.diagnostic.severity.HINT] = '',
      [vim.diagnostic.severity.INFO] = '',
    },
  },
})
