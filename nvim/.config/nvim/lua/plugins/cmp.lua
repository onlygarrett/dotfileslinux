local function ensure_copilot_source_in_sources(sources)
  local has = false
  for _, s in ipairs(sources or {}) do
    if s and s.name == "copilot" then
      has = true
      break
    end
  end
  if not has then
    table.insert(sources, 1, { name = "copilot", group_index = 2 })
  end
  return sources
end

local function add_or_replace_comparator(comparators, comparator_fn, key)
  -- If a comparator with the same identity exists, replace it; otherwise insert at head.
  local inserted = false
  for i, c in ipairs(comparators or {}) do
    -- We can't easily compare functions by value; just insert at the front to ensure priority.
    -- If you prefer a specific spot, you can adjust index logic here.
  end
  table.insert(comparators, 1, comparator_fn)
  return comparators
end

local function copilot_cmp_debug()
  local lines = {}
  local ok_cmp, cmp = pcall(require, "cmp")
  local ok_cp, copilot = pcall(require, "copilot")
  local ok_ccmp, ccmp = pcall(require, "copilot_cmp")

  table.insert(lines, "=== CopilotCmp Debug ===")
  table.insert(lines, ("cmp module: %s"):format(ok_cmp and "loaded" or "NOT loaded"))
  table.insert(lines, ("copilot module: %s"):format(ok_cp and "loaded" or "NOT loaded"))
  table.insert(lines, ("copilot_cmp module: %s"):format(ok_ccmp and "loaded" or "NOT loaded"))

  if ok_cmp then
    local cfg = cmp.get_config()
    table.insert(lines, "--- cmp sources ---")
    for i, s in ipairs(cfg.sources or {}) do
      table.insert(lines, ("%2d: %s (group_index=%s)"):format(i, s.name or "?", tostring(s.group_index)))
    end
    table.insert(lines, "--- cmp comparators ---")
    local comps = cfg.sorting and cfg.sorting.comparators or {}
    for i, _ in ipairs(comps) do
      table.insert(lines, ("%2d: <function>"):format(i))
    end
  end

  -- Copilot status
  local status = "unknown"
  if ok_cp and copilot and copilot.status then
    local s = copilot.status.data or {}
    status = ("status=%s auth=%s"):format(s.status or "?", s.authenticated and "yes" or "no")
  end
  table.insert(lines, ("copilot status: %s"):format(status))

  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end

local function setup_debug_command()
  vim.api.nvim_create_user_command("CopilotCmpDebug", copilot_cmp_debug, {})
end

return {
  "hrsh7th/nvim-cmp",
  -- Use opts mutator to merge into existing LazyVim cmp config instead of replacing it
  opts = function(_, opts)
    local cmp = require("cmp")
    local ok_prior, coprior = pcall(require, "copilot_cmp.comparators")

    -- Ensure sources includes copilot (preserve your grouping)
    opts.sources = cmp.config.sources(ensure_copilot_source_in_sources(opts.sources or {
      { name = "nvim_lsp", group_index = 2 },
      { name = "buffer", group_index = 2 },
    }))

    -- Disable preselection to avoid accidental accepts
    opts.preselect = cmp.PreselectMode.None

    -- Merge sorting comparators with copilot prioritizer at the front
    opts.sorting = opts.sorting or {}
    opts.sorting.priority_weight = opts.sorting.priority_weight or 2
    opts.sorting.comparators = opts.sorting.comparators
      or {
        cmp.config.compare.offset,
        cmp.config.compare.exact,
        cmp.config.compare.score,
        cmp.config.compare.recently_used,
        cmp.config.compare.locality,
        cmp.config.compare.kind,
        cmp.config.compare.sort_text,
        cmp.config.compare.length,
        cmp.config.compare.order,
      }
    if ok_prior and coprior and coprior.prioritize then
      opts.sorting.comparators =
        add_or_replace_comparator(opts.sorting.comparators, coprior.prioritize, "copilot_prioritize")
    end

    -- Preserve your window borders
    opts.window = opts.window or {}
    opts.window.completion = opts.window.completion or cmp.config.window.bordered()
    opts.window.documentation = opts.window.documentation or cmp.config.window.bordered()

    -- Preserve your mappings; if mappings are already present, keep them
    opts.mapping = opts.mapping
      or cmp.mapping.preset.insert({
        ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
      })

    -- Add simple formatting to show [AI] for copilot items; keeps existing formatting if present
    local original_format = opts.formatting and opts.formatting.format
    opts.formatting = opts.formatting or {}
    opts.formatting.format = function(entry, vim_item)
      local menu = {
        copilot = "[AI]",
        nvim_lsp = "[LSP]",
        buffer = "[Buf]",
        path = "[Path]",
        cmdline = "[Cmd]",
        luasnip = "[Snip]",
      }
      vim_item.menu = menu[entry.source.name] or ("[" .. entry.source.name .. "]")
      if original_format then
        -- Let any existing formatter run after we tag the menu
        vim_item = original_format(entry, vim_item) or vim_item
      end
      return vim_item
    end

    -- Optional: Avoid ghost_text conflicts (Copilot ghost text handled by copilot.lua)
    opts.experimental = opts.experimental or {}
    if opts.experimental.ghost_text == nil then
      opts.experimental.ghost_text = false
    end

    -- Register debug command
    setup_debug_command()
  end,

  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "zbirenbaum/copilot-cmp",
  },

  -- Let LazyVim decide event timing; you used VeryLazy before. Keeping it is fine.
  event = "VeryLazy",
}
