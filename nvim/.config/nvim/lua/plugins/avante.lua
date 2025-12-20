-- ~/.config/nvim/lua/plugins/avante.lua
-- Avante.nvim configuration UPDATED for provider migration
-- Ollama + qwen2.5-coder:14b
-- Explicit, non-streaming, tool-stable configuration

return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false,
  build = "make",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
    {
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {},
    },
    {
      "zbirenbaum/copilot.lua",
      lazy = true,
      opts = {},
    },
  },
  opts = {
    ---------------------------------------------------------------------------
    -- Provider selection
    ---------------------------------------------------------------------------
    provider = "ollama",

    ---------------------------------------------------------------------------
    -- NEW provider-based configuration (NO deprecations)
    ---------------------------------------------------------------------------
    providers = {
      ollama = {
        endpoint = "http://127.0.0.1:11434",
        model = "qwen2.5-coder:14b",

        -- absolutely critical: disable streaming for Qwen
        stream = false,

        -- request body passed verbatim to Ollama
        extra_request_body = {
          options = {
            temperature = 0.2,
            top_p = 0.9,
            top_k = 40,
            num_ctx = 8192,
            repeat_penalty = 1.1,
            stop = {
              "</s>",
              "<|endoftext|>",
              "<|im_end|>",
              "<|end|>",
            },
          },
        },
      },
    },

    ---------------------------------------------------------------------------
    -- System prompt (kept brutally strict to prevent looping)
    ---------------------------------------------------------------------------
    system_prompt = table.concat({
      "You are a Neovim coding assistant.",
      "Only output final answers.",
      "Never repeat the question.",
      "Never explain reasoning.",
      "Never describe tools or actions.",
      "When editing code, output only the replacement content.",
      "Never loop or re-answer.",
    }, "\n"),

    ---------------------------------------------------------------------------
    -- Tool configuration
    ---------------------------------------------------------------------------
    tools = {
      edit = {
        enabled = true,
        replace_entire_file = true,
      },
      web = { enabled = false },
      browse = { enabled = false },
      search = { enabled = false },
    },

    ---------------------------------------------------------------------------
    -- Behavior tuning (fixes edit + diff bugs)
    ---------------------------------------------------------------------------
    behaviour = {
      auto_suggestions = false,
      auto_apply_diff_after_generation = true,
      support_paste_from_clipboard = true,
      minimize_diff = false,
    },

    ---------------------------------------------------------------------------
    -- Diff engine configuration
    ---------------------------------------------------------------------------
    diff = {
      algorithm = "minimal",
      ctxlen = 3,
    },

    ---------------------------------------------------------------------------
    -- Window layout
    ---------------------------------------------------------------------------
    windows = {
      position = "right",
      width = 45,
      wrap = true,
    },

    ---------------------------------------------------------------------------
    -- Keymaps
    ---------------------------------------------------------------------------
    mappings = {
      ask = "<leader>aa",
      edit = "<leader>ae",
      refresh = "<leader>ar",
      focus = "<leader>af",
      close = "<leader>ac",
    },

    ---------------------------------------------------------------------------
    -- Debugging (leave on until fully stable)
    ---------------------------------------------------------------------------
    debug = true,
  },
}
