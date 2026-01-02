return {
  "folke/edgy.nvim",
  event = "VeryLazy",
  opts = {
    bottom = {
      {
        ft = "toggleterm",
        size = { height = 0.35 },
        filter = function(buf)
          return vim.b[buf].term_type == "terminal"
        end,
      },
      "Trouble",
      { ft = "qf", title = "QuickFix" },
      {
        ft = "help",
        size = { height = 0.35 },
        filter = function(buf)
          return vim.bo[buf].buftype == "help"
        end,
      },
    },
    left = {
      { title = "Files", ft = "neo-tree", filter = function(buf) return vim.bo[buf].ft == "neo-tree" end },
      { title = "Outline", ft = "Outline" },
    },
    right = {},
    top = {},
  },
}
