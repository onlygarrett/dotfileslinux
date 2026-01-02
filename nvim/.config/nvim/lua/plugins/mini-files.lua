return {
  "nvim-mini/mini.files",
  version = "*",
  keys = {
    {
      "<leader>fm",
      function()
        local bufname = vim.api.nvim_buf_get_name(0)
        require("mini.files").open(bufname ~= "" and bufname or nil, false)
      end,
      desc = "Mini Files (here)",
    },
    {
      "<leader>fM",
      function()
        require("mini.files").open(vim.loop.cwd(), false)
      end,
      desc = "Mini Files (cwd)",
    },
  },
  opts = {
    windows = {
      width_focus = 30,
      width_preview = 40,
    },
    options = {
      use_as_default_explorer = false,
    },
  },
  config = function(_, opts)
    require("mini.files").setup(opts)
  end,
}
