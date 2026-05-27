-- Configure Python LSP to work with Poetry and virtual environments
return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    -- Function to get Poetry virtualenv path for current project
    local function get_poetry_venv()
      local handle = io.popen("cd " .. vim.fn.getcwd() .. " && poetry env info --path 2>/dev/null")
      if handle then
        local result = handle:read("*a")
        handle:close()
        result = result:gsub("%s+", "") -- trim whitespace
        if result ~= "" then
          return result .. "/bin/python"
        end
      end
      return nil
    end

    -- Get Poetry venv or fall back to system python
    local python_path = get_poetry_venv() or vim.fn.exepath("python3") or vim.fn.exepath("python")

    opts.servers = opts.servers or {}
    opts.servers.basedpyright = {
      settings = {
        basedpyright = {
          analysis = {
            autoSearchPaths = true,
            diagnosticMode = "openFilesOnly",
            useLibraryCodeForTypes = true,
            typeCheckingMode = "basic",
            venvPath = vim.fn.expand("~/.config/cache/pypoetry/virtualenvs"),
          },
        },
      },
      before_init = function(_, config)
        -- Set python path if we found a Poetry venv
        local poetry_python = get_poetry_venv()
        if poetry_python then
          config.settings.python = config.settings.python or {}
          config.settings.python.pythonPath = poetry_python
        end
      end,
    }
    return opts
  end,
}
