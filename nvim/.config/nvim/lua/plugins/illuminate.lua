return {
  "RRethy/vim-illuminate",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    delay = 150,
    filetypes_denylist = { "dirbuf", "TelescopePrompt", "snacks_dashboard", "snacks_layout_box" },
  },
  config = function(_, opts)
    local ok, illuminate = pcall(require, "illuminate")
    if not ok then
      return
    end

    illuminate.configure(opts)

    local function map(bufnr, lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { silent = true, buffer = bufnr, desc = desc })
    end

    local group = vim.api.nvim_create_augroup("IlluminateKeymaps", { clear = true })
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
      group = group,
      callback = function(event)
        map(event.buf, "]r", function()
          illuminate.goto_next_reference(false)
        end, "Next reference")
        map(event.buf, "[r", function()
          illuminate.goto_prev_reference(false)
        end, "Prev reference")
      end,
    })
  end,
}
