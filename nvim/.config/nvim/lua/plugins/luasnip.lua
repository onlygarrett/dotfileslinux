return {
  "L3MON4D3/LuaSnip",
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  event = "InsertEnter",
  opts = {
    history = true,
    update_events = "TextChanged,TextChangedI",
    region_check_events = "InsertEnter",
    delete_check_events = "TextChanged",
  },
  config = function(_, opts)
    local ls = require("luasnip")

    ls.config.setup(opts)

    local ok_loader, loader = pcall(require, "luasnip.loaders.from_vscode")
    if ok_loader then
      loader.lazy_load()
    end

    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
    end

    map({ "i", "s" }, "<C-j>", function()
      if ls.jumpable(1) then
        ls.jump(1)
      end
    end, "Next snippet field")

    map({ "i", "s" }, "<C-k>", function()
      if ls.jumpable(-1) then
        ls.jump(-1)
      end
    end, "Previous snippet field")

    map({ "i", "s" }, "<C-l>", function()
      if ls.choice_active() then
        ls.change_choice(1)
      end
    end, "Next snippet choice")
  end,
}
