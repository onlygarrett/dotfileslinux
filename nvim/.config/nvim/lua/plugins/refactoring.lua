return {
  "ThePrimeagen/refactoring.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  cmd = {
    "Refactor",
    "Refactoring",
  },
  keys = {
    {
      "<leader>rr",
      function()
        require("refactoring").select_refactor()
      end,
      mode = { "n", "v" },
      desc = "Refactor",
    },
  },
  opts = {
    prompt_func_return_type = {
      go = true,
      java = true,
      cpp = true,
      c = true,
      h = true,
      hpp = true,
      cxx = true,
    },
    prompt_func_param_type = {
      go = true,
      java = true,
      cpp = true,
      c = true,
      h = true,
      hpp = true,
      cxx = true,
    },
  },
  config = function(_, opts)
    require("refactoring").setup(opts)
  end,
}
