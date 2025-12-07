local vim = vim

local X = {}

-- Attach LSP client to buffer
function X.on_attach(on_attach)
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local buffer = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      on_attach(client, buffer)
    end,
  })
end

function X.starts_with(str, start)
  return str:sub(1, #start) == start
end

function X.is_table(to_check)
  return type(to_check) == "table"
end

function X.has_key(t, key)
  return t[key] ~= nil
end

function X.extract_zip(zip_path)
  local zipdir = vim.fn.fnamemodify(zip_path, ":h")
  vim.fn.jobstart({ "unzip", "-o", zip_path, "-d", zipdir }, {
    on_exit = function(_, code)
      print("Unzip finished with exit code: " .. code)
    end,
  })
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "zip",
  callback = function()
    vim.api.nvim_buf_create_user_command(0, "ExtractZip", X.extract_zip, {})
  end,
})

function X.has_value(t, val)
  for _, value in ipairs(t) do
    if value == val then
      return true
    end
  end
  return false
end

function X.tprint(tbl)
  print(vim.inspect(tbl))
end

function X.tprint_keys(tbl)
  for k in pairs(tbl) do
    print(k)
  end
end

X.reload = function()
  local presentReload, reload = pcall(require, "plenary.reload")
  if presentReload then
    local counter = 0
    for moduleName in pairs(package.loaded) do
      if X.starts_with(moduleName, "lt.") then
        reload.reload_module(moduleName)
        counter = counter + 1
      end
    end
    vim.g.mapper_records = nil
    vim.notify("Reloaded " .. counter .. " modules!")
  end
end

function X.is_macunix()
  return vim.fn.has("macunix") == 1
end

function X.link_highlight(from, to, override)
  local hl_exists = vim.api.nvim_get_hl(0, { name = from, link = false }) ~= nil
  if override or not hl_exists then
    vim.api.nvim_set_hl(0, from, { link = to })
  end
end

-- Highlight group utilities
X.highlight = function(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

X.highlight_bg = function(group, col)
  vim.api.nvim_set_hl(0, group, { bg = col })
end

X.highlight_fg = function(group, col)
  vim.api.nvim_set_hl(0, group, { fg = col })
end

X.highlight_fg_bg = function(group, fgcol, bgcol)
  vim.api.nvim_set_hl(0, group, { fg = fgcol, bg = bgcol })
end

X.from_highlight = function(hl)
  local result = {}
  local list = vim.api.nvim_get_hl_by_name(hl, true)
  for k, v in pairs(list) do
    local name = k == "background" and "bg" or "fg"
    result[name] = string.format("#%06x", v)
  end
  return result
end

X.get_color_from_terminal = function(num, default)
  local key = "terminal_color_" .. num
  return vim.g[key] or default
end

X.cmd = function(name, command, desc)
  vim.api.nvim_create_user_command(name, command, desc)
end

X.autocmd = function(evt, opts)
  vim.api.nvim_create_autocmd(evt, opts)
end
return X
