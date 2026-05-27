-- ~/.config/nvim/lua/plugins/venv-selector.lua
return {
  "linux-cultist/venv-selector.nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
    "mfussenegger/nvim-dap",
    "mfussenegger/nvim-dap-python",
    { "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } },
  },
  branch = "main",
  event = "VeryLazy",
  opts = function()
    return {
      settings = {
        options = {
          on_telescope_result_callback = nil,
          enable_default_searches = true,
          enable_cached_venvs = true,
          cached_venv_automatic_activation = false, -- we'll handle this manually
          activate_venv_in_terminal = true,
          notify_user_on_venv_activation = true,
          -- Search order: look for Poetry virtualenvs first
          search = {
            poetry_config = {
              command = "fd python$ " .. vim.fn.expand("~/.config/cache/pypoetry/virtualenvs") .. " --full-path --color never -L -E .DS_Store -d 3 -t f",
              type = "anaconda",
            },
            poetry = {
              command = "fd python$ ~/.cache/pypoetry/virtualenvs --full-path --color never -L -E .DS_Store -d 3 -t f",
              type = "anaconda",
            },
            venvs = { command = "fd -t d -a -H -E .git -E node_modules . ~/.virtualenvs", type = "anaconda" },
            cwd = { command = "fd -t d -a -H -E .git -E node_modules python$ . --full-path -d 3 -t f", type = "anaconda" },
          },
        },
      },
    }
  end,
  keys = {
    { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv" },
    { "<leader>cV", "<cmd>VenvSelectCached<cr>", desc = "Select Cached VirtualEnv" },
  },
}
