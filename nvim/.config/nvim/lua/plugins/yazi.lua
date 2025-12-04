return {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  keys = {
    {
      desc = "Open yazi at the current file",
      "<leader>o",
      "<cmd>Yazi<cr>",
    },
    {
      desc = "Open the file manager in nvim's working directory",
      "<leader>cw",
      "<cmd>Yazi cwd<cr>",
    },
    {
      desc = "Resume the last yazi session",
      "<c-up>",
      "<cmd>Yazi toggle<cr>",
    },
  },
  opts = {
    -- replace netrw with yazi
    open_for_directories = true,
    keymaps = {
      show_help = "<f1>",
    },
  },
}
