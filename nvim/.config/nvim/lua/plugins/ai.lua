-- ~/.config/nvim/lua/plugins/ai.lua

return {
  -- Keep using LazyVim's Copilot extra
  { import = "lazyvim.plugins.extras.ai.copilot" },

  -- Copilot core plugin
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        -- If you decide to re-enable keymaps, you can uncomment below:
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
    -- Important: make sure copilot-cmp initializes after copilot.lua
    dependencies = {
      {
        "zbirenbaum/copilot-cmp",
        -- Explicit setup to guarantee source registration
        config = function()
          local ok, copilot_cmp = pcall(require, "copilot_cmp")
          if not ok then
            return
          end
          copilot_cmp.setup({
            method = "getCompletionsCycling",
            -- Use default formatters; you can tweak to avoid duplicate insert text
            formatters = {
              insert_text = require("copilot_cmp.format").remove_existing,
            },
          })
        end,
      },
    },
  },

  -- CopilotChat - keep your existing customizations
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
