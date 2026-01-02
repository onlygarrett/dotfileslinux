return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    indent = { char = "│" },
    scope = { enabled = true, show_start = false, show_end = false },
    exclude = {
      filetypes = { "help", "lazy", "mason", "dashboard", "snacks_dashboard", "snacks_layout_box" },
    },
  },
  config = function(_, opts)
    require("ibl").setup(opts)
  end,
}
