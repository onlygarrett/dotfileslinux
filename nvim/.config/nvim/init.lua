-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("config.commands")
vim.env.PATH = vim.env.PATH .. ";C:\\Program Files\\Git\\cmd"
--
-- vim.opt.shell = "C:\\Windows\\System32\\cmd.exe"
-- vim.opt.shellcmdflag = "/c"
-- vim.g.lazy_git_cmd = "C:\\Program Files\\Git\\cmd\\git.exe"
