return {
  "hedyhli/outline.nvim",
  cmd = { "Outline", "OutlineOpen" },
  keys = {
    {
      "<leader>o",
      function()
        require("outline").toggle({ focus_outline = true })
      end,
      desc = "Toggle Outline",
    },
  },
  opts = {
    outline_window = {
      position = "right",
      width = 30,
      auto_close = false,
    },
    guides = {
      enabled = true,
    },
  },
  config = function(_, opts)
    require("outline").setup(opts)
  end,
}
