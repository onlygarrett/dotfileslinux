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

-- fix snacks explorer sidebar width so it doesn't resize on window focus changes
-- snacks' WinResized handler actively resizes the root split win, so we fight back
-- by restoring the configured width after any resize event
local explorer_width = 40
vim.api.nvim_create_autocmd("WinResized", {
  group = vim.api.nvim_create_augroup("snacks_explorer_fixwidth", { clear = true }),
  callback = function()
    local pickers = Snacks.picker.get({ source = "explorer" })
    local picker = pickers and pickers[1]
    if not picker then
      return
    end
    local layout = picker.layout
    if not layout or not layout.root or not layout.root:win_valid() then
      return
    end
    local root_win = layout.root.win
    if vim.api.nvim_win_get_width(root_win) ~= explorer_width then
      vim.api.nvim_win_set_width(root_win, explorer_width)
    end
  end,
})

-- Auto-activate Poetry virtualenv for Python projects
require("config.python-poetry").setup()
