return {
  "olimorris/codecompanion.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "hrsh7th/nvim-cmp" },
  config = function()
    local cc = require("codecompanion")

    -- Ollama adapter (OpenAI-compatible)
    local ollama_adapter = {
      name = "qwen-ollama",
      schema = {
        model = { type = "string", default = "qwen2.5-coder:14b" },
        temperature = { type = "number", default = 0.2 },
        top_p = { type = "number", default = 0.9 },
        presence_penalty = { type = "number", default = 0.0 },
        frequency_penalty = { type = "number", default = 0.0 },
        max_tokens = { type = "number", default = 2048 },
        stream = { type = "boolean", default = true },
        base_url = { type = "string", default = "http://127.0.0.1:11434" },
      },
      request = {
        url = "/v1/chat/completions",
        headers = {
          ["Content-Type"] = "application/json",
        },
        body = function(self, params)
          return {
            model = params.model,
            temperature = params.temperature,
            top_p = params.top_p,
            presence_penalty = params.presence_penalty,
            frequency_penalty = params.frequency_penalty,
            max_tokens = params.max_tokens,
            stream = params.stream,
            messages = params.messages,
          }
        end,
      },
      response = {
        handler = function(_, body)
          return body
        end,
        stream = function(callback, data)
          callback(data)
        end,
      },
    }

    cc.setup({
      -- Ensure this is always a table so pairs() never sees nil
      keymaps = {},

      adapters = {
        ollama = function()
          return require("codecompanion.adapters").extend("ollama", ollama_adapter)
        end,
      },

      strategies = {
        chat = {
          adapter = "ollama",
          -- Use defaults for keymaps to avoid nil; customize later if needed
        },
        inline = {
          adapter = "ollama",
        },
      },

      display = {
        chat = { render_headers = true },
      },
    })

    -- Keymaps to open chat/inline (these are separate from CodeCompanion's internal keymaps)
    vim.keymap.set("n", "<leader>ce", "<cmd>CodeCompanionChat<cr>", { desc = "Chat (Ollama/Qwen)" })
    vim.keymap.set("v", "<leader>cE", "<cmd>CodeCompanionInline<cr>", { desc = "Inline edit (selection)" })
  end,
}
