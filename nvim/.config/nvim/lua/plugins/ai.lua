-- ~/.config/nvim/lua/plugins/ai.lua
return {

  { import = "lazyvim.plugins.extras.ai.copilot" },
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        -- keymap = {
        --   accept = "<M-CR>",
        --   accept_line = "<M-l>",
        --   accept_word = "<M-k>",
        --   next = "<M-]>",
        --   prev = "<M-[>",
        --   dismiss = "<M-c>",
        -- },
      },
    },
    keys = {
      { "<leader>cI", "<cmd>Copilot toggle<cr>", desc = "Toggle IA (Copilot)" },
    },
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    opts = function(_, opts)
      opts.context = vim.tbl_extend("force", opts.context or {}, {
        cwd_files = function()
          local cwd = vim.fn.getcwd()
          local files = {}

          local handle = io.popen(
            "find "
              .. cwd
              .. " -type f "
              .. " -not -path '*/.git/*'"
              .. " -not -path '*/node_modules/*'"
              .. " -not -path '*/.venv/*'"
              .. " -maxdepth 3"
          )

          if handle then
            for file in handle:lines() do
              table.insert(files, file)
            end
            handle:close()
          end

          return files
        end,
      })

      return opts
    end,
    config = function(_, opts)
      require("CopilotChat").setup(opts)

      -- Automatically set context to cwd_files when chat opens
      vim.api.nvim_create_autocmd("User", {
        pattern = "CopilotChatOpen",
        callback = function()
          require("CopilotChat.context").set_context("cwd_files")
        end,
      })
    end,
  },
}
