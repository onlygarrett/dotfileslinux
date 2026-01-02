local function extend(list, extras)
  if not extras or #extras == 0 then
    return list
  end
  list = list or {}
  for _, item in ipairs(extras) do
    if not vim.tbl_contains(list, item) then
      table.insert(list, item)
    end
  end
  return list
end

return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = extend(opts.ensure_installed, {
        "docker-compose-language-service",
        "dockerfile-language-server",
        "json-lsp",
        "marksman",
        "sqls",
        "terraform-ls",
        "tflint",
        "taplo",
        "typescript-language-server",
        "gopls",
      })
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = extend(opts.ensure_installed, {
        "dockerls",
        "docker_compose_language_service",
        "jsonls",
        "marksman",
        "sqls",
        "terraformls",
        "taplo",
        "eslint",
        "gopls",
        "lua_ls",
        "yamlls",
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = extend(opts.ensure_installed, {
        "dockerfile",
        "gitcommit",
        "hcl",
        "json",
        "markdown",
        "markdown_inline",
        "sql",
        "terraform",
        "toml",
        "typescript",
        "javascript",
      })
    end,
  },
  {
    "b0o/SchemaStore.nvim",
    lazy = true,
  },
  {
    "jose-elias-alvarez/typescript.nvim",
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    opts = {},
  },
}
