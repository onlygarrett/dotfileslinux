return {
  "ahmedkhalf/project.nvim",
  event = "VeryLazy",
  opts = {
    detection_methods = { "lsp", "pattern" },
    patterns = { ".git", "package.json", "pyproject.toml", "Makefile", "go.mod", "Cargo.toml", "composer.json" },
    silent_chdir = true,
  },
  config = function(_, opts)
    require("project_nvim").setup(opts)
    require("telescope").load_extension("projects")
  end,
}
