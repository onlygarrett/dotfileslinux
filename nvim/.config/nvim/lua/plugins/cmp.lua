-- Ensures load order: copilot.lua -> copilot-cmp -> cmp setup.

local function _1_()
  local cmp = require("cmp")
  local copilot_cmp_comparators = require("copilot_cmp.comparators")

  -- Optional formatting for clearer source labels, including Copilot
  local formatting = {
    format = function(entry, vim_item)
      -- Basic kind text; you can switch to lspkind if you use it
      local menu = {
        copilot = "[AI]",
        nvim_lsp = "[LSP]",
        buffer = "[Buf]",
        path = "[Path]",
        cmdline = "[Cmd]",
        luasnip = "[Snip]",
      }
      vim_item.menu = menu[entry.source.name] or ("[" .. entry.source.name .. "]")
      return vim_item
    end,
  }

  cmp.setup({
    -- Preserve your sources and group_index arrangement; copilot included and grouped
    sources = cmp.config.sources({
      { name = "copilot", group_index = 2 },
      { name = "nvim_lsp", group_index = 2 },
      { name = "buffer", group_index = 2 },
      -- You can add more sources here while keeping group_index semantics
      { name = "path", group_index = 2 },
      { name = "luasnip", group_index = 2 },
    }),

    sorting = {
      priority_weight = 2,
      comparators = {
        copilot_cmp_comparators.prioritize,
        cmp.config.compare.offset,
        cmp.config.compare.exact,
        cmp.config.compare.score,
        cmp.config.compare.recently_used,
        cmp.config.compare.locality,
        cmp.config.compare.kind,
        cmp.config.compare.sort_text,
        cmp.config.compare.length,
        cmp.config.compare.order,
      },
    },

    -- Preserve your window settings
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },

    mapping = cmp.mapping.preset.insert({
      ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
      ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.abort(),
      ["<CR>"] = cmp.mapping.confirm({ select = false }),
    }),

    -- Add formatting so Copilot entries are visible with [AI] tag
    formatting = formatting,
  })

  -- Preserve your cmdline setup
  return cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({ { name = "path" }, { name = "cmdline" } }),
    matching = { disallow_symbol_nonprefix_matching = false },
  })
end

return {
  "hrsh7th/nvim-cmp",
  config = _1_,
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    -- Ensure copilot-cmp is present so the copilot source is available
    "zbirenbaum/copilot-cmp",
  },
  -- You used VeryLazy; keep it if you prefer, but InsertEnter is also common.
  event = "VeryLazy",
  main = "cmp",
}
