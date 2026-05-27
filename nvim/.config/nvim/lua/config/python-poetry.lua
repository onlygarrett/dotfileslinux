-- Auto-detect and activate Poetry virtualenv for Python projects
local M = {}

-- Function to detect if current directory is a Poetry project
local function is_poetry_project()
  local pyproject = vim.fn.findfile("pyproject.toml", ".;")
  if pyproject == "" then
    return false
  end

  -- Check if pyproject.toml contains poetry
  local file = io.open(pyproject, "r")
  if file then
    local content = file:read("*all")
    file:close()
    return content:match("%[tool%.poetry%]") ~= nil
  end
  return false
end

-- Function to get Poetry virtualenv path
local function get_poetry_venv_path()
  local handle = io.popen("cd " .. vim.fn.getcwd() .. " && poetry env info --path 2>/dev/null")
  if handle then
    local result = handle:read("*a")
    handle:close()
    result = result:gsub("%s+", "")
    if result ~= "" and result ~= "null" then
      return result
    end
  end
  return nil
end

-- Function to activate Poetry venv
function M.activate_poetry_venv()
  if not is_poetry_project() then
    return
  end

  local venv_path = get_poetry_venv_path()
  if venv_path then
    local python_path = venv_path .. "/bin/python"

    -- Set environment variables
    vim.env.VIRTUAL_ENV = venv_path
    vim.env.PATH = venv_path .. "/bin:" .. vim.env.PATH

    -- Try to activate using venv-selector if available
    local has_venv_selector, venv_selector = pcall(require, "venv-selector")
    if has_venv_selector then
      vim.schedule(function()
        -- Just set the cache file manually if the API doesn't work
        local cache_file = vim.fn.stdpath("cache") .. "/venv-selector/venvs"
        local cache_dir = vim.fn.fnamemodify(cache_file, ":h")
        vim.fn.mkdir(cache_dir, "p")

        -- Write the venv path to cache
        local file = io.open(cache_file, "w")
        if file then
          file:write(python_path .. "\n")
          file:close()
        end
      end)
    end

    -- Notify user
    vim.notify("Activated Poetry venv: " .. venv_path, vim.log.levels.INFO)

    -- Restart LSP to pick up the new Python path
    vim.schedule(function()
      vim.cmd("LspRestart")
    end)
  end
end

-- Setup autocmd to activate Poetry venv when opening Python files
function M.setup()
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    pattern = { "*.py" },
    callback = function()
      -- Only run once per session for this directory
      local cwd = vim.fn.getcwd()
      if not M._activated_dirs then
        M._activated_dirs = {}
      end
      if not M._activated_dirs[cwd] then
        M._activated_dirs[cwd] = true
        M.activate_poetry_venv()
      end
    end,
    desc = "Auto-activate Poetry virtualenv for Python files",
  })
end

return M
