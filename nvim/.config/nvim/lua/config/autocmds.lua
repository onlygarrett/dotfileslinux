-- this is for snacks explorer auto refresh on buffer enter
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vim.api.nvim_create_augroup("snacks_explorer_autorefresh", { clear = true }),
  callback = function(event)
    local picker = Snacks.picker.get({ source = "explorer" })[1]
    if not picker or picker:cwd() == LazyVim.root() then
      return
    end
    -- Variant 1: change directory
    local A = require("snacks.explorer.actions")
    pcall(function()
      picker:set_cwd(vim.fn.expand("%:p:h"))
      A.actions.explorer_update(picker)
    end)
    -- Variant 2: reveal the buffer/file
    -- local E = require 'snacks.explorer'
    -- E.reveal(event.buf)
  end,
})
