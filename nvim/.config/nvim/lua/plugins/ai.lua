-- ~/.config/nvim/lua/plugins/ai.lua
-- Deterministic Copilot + copilot-cmp initialization and CopilotChat config,
-- ensuring copilot-cmp is set up AFTER Copilot is initialized to avoid race conditions.

return {
  -- { import = "lazyvim.plugins.extras.ai.copilot" },

  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    opts = {
      -- Disable inline suggestions so they do NOT appear automatically.
      suggestion = {
        enabled = false, -- was true; set to false to stop ghost text
        auto_trigger = false, -- keep false to avoid auto popup even if enabled later
      },
      -- Liberal filetype defaults: enabled everywhere unless explicitly turned off
      filetypes = {
        ["*"] = true,
        ["dap-repl"] = false,
        ["TelescopePrompt"] = false,
        ["neo-tree-popup"] = false,
        -- Add disables if you want to limit Copilot:
        -- ["help"] = false,
        -- ["gitcommit"] = true,
        -- ["markdown"] = true,
      },
      -- If Node is not on PATH or you use a custom path, uncomment and set explicitly:
      -- copilot_node_command = "/usr/bin/node",
    },
    keys = {
      { "<leader>cI", "<cmd>Copilot toggle<cr>", desc = "Toggle IA (Copilot)" },
      { "<leader>ae", "<cmd>CopilotChatToggle<cr>", desc = "Toggle Chat (Copilot)" },
    },
    dependencies = {
      -- keep copilot-cmp as a dependency but DO NOT configure it here
      "zbirenbaum/copilot-cmp",
      "hrsh7th/nvim-cmp",
    },
    config = function(_, opts)
      -- 1) Initialize Copilot first
      require("copilot").setup(opts)

      -- 2) Then, initialize copilot-cmp immediately after Copilot is ready
      local ok_cmp_bridge, copilot_cmp = pcall(require, "copilot_cmp")
      if not ok_cmp_bridge then
        vim.schedule(function()
          vim.notify("copilot-cmp not found; Copilot CMP integration will be disabled", vim.log.levels.WARN)
        end)
        return
      end

      local ok_cmp, cmp = pcall(require, "cmp")
      if not ok_cmp then
        local ok_lazy, lazy = pcall(require, "lazy")
        if ok_lazy and lazy and lazy.load then
          lazy.load({ plugins = { "nvim-cmp" } })
        end
        ok_cmp, cmp = pcall(require, "cmp")
      end
      if not ok_cmp then
        vim.schedule(function()
          vim.notify("nvim-cmp not available; copilot-cmp disabled", vim.log.levels.WARN)
        end)
        return
      end

      copilot_cmp.setup({
        method = "getCompletionsCycling",
        formatters = {
          insert_text = require("copilot_cmp.format").remove_existing,
        },
      })

      -- Attach Copilot completion source to cmp if available
      local ok_adapter, cmp_adapter = pcall(require, "copilot_cmp.comparators")
      if ok_adapter and cmp and cmp.setup then
        -- If cmp was already configured elsewhere, ensure the source is available at runtime
        local cfg = cmp.get_config()
        local has_source = false
        for _, src in ipairs(cfg.sources or {}) do
          if src.name == "copilot" then
            has_source = true
            break
          end
        end
        if not has_source then
          table.insert(cfg.sources, 1, { name = "copilot", group_index = 2 })
          cmp.setup(cfg)
        end
      end
    end,
  },
}
