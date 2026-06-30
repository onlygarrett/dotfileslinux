-- Force LazyVim to use nvim-cmp instead of blink.cmp
vim.g.lazyvim_cmp = "nvim-cmp"

-- Disable AI ghost text in completions (prevents inline suggestions from pushing text around)
vim.g.ai_cmp = false

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("config.commands")
