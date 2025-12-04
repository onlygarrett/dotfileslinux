--                                     ██
--                                    ░░
--  ███████   █████   ██████  ██    ██ ██ ██████████
-- ░░██░░░██ ██░░░██ ██░░░░██░██   ░██░██░░██░░██░░██
--  ░██  ░██░███████░██   ░██░░██ ░██ ░██ ░██ ░██ ░██
--  ░██  ░██░██░░░░ ░██   ░██ ░░████  ░██ ░██ ░██ ░██
--  ███  ░██░░██████░░██████   ░░██   ░██ ███ ░██ ░██
-- ░░░   ░░  ░░░░░░  ░░░░░░     ░░    ░░ ░░░  ░░  ░░
--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ jeedev
-- ░▓▓▓▓▓▓▓▓▓▓
-- ░░░░░░░░░░
--

local r = require("config.remaps")
local f = require("config.functions")

-- vim.g.mapleader = " "
-- local keymap = vim.keymap

r.noremap("i", "jk", "<ESC>", "Exit insert mode with jk")

-- scrolling
-- r.noremap("n", "<C-D>", "<C-d>zz")
-- r.noremap("n", "<C-U>", "<C-u>zz")

r.noremap("n", "QQ", ":q!<CR>", "Force quit")
r.noremap("n", "WW", ":w!<CR>", "Force save")
r.noremap("n", "<leader>qq", ":q<CR>", "Quit", { silent = true })

-- window management
r.noremap("n", "<leader>sv", "<C-w>v", "Split window vertically") -- split window vertically
r.noremap("n", "<leader>sh", "<C-w>s", "Split window horizontally") -- split window horizontally
r.noremap("n", "<leader>se", "<C-w>=", "Make splits equal size") -- make split windows equal width & height
r.noremap("n", "<leader>sx", "<cmd>close<CR>", "Close current split") -- close current split window

r.noremap("n", "<C-a>", "gg<S-v>G")
r.noremap("n", "<leader>to", "<cmd>tabnew<CR>", "Open new tab") -- open new tab
r.noremap("n", "<leader>tx", "<cmd>tabclose<CR>", "Close current tab") -- close current tab
r.noremap("n", "<leader>tn", "<cmd>tabn<CR>", "Go to next tab") --  go to next tab
r.noremap("n", "<leader>tp", "<cmd>tabp<CR>", "Go to previous tab") --  go to previous tab
r.noremap("n", "<leader>tf", "<cmd>tabnew %<CR>", "Open current buffer in new tab") --  move current buffer to new tab

-- functions/commands
-- remove trailing white space
f.cmd("Nows", "%s/\\s\\+$//e", { desc = "remove trailing whitespace" })

-- remove blank lines
f.cmd("Nobl", "g/^\\s*$/d", { desc = "remove blank lines" })
