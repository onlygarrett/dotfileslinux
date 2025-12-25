-- ~/.config/nvim/lua/plugins/ai.lua
-- Deterministic Copilot + copilot-cmp initialization and CopilotChat config,
-- ensuring copilot-cmp is set up AFTER Copilot is initialized to avoid race conditions.

local function copilot_runtime_checks()
  -- Node availability check (best-effort; will not block)
  local node = vim.fn.exepath("node")
  if node == "" then
    vim.schedule(function()
      vim.notify(
        "Copilot requires Node.js but none was found in PATH. Install Node and restart Neovim.",
        vim.log.levels.ERROR
      )
    end)
  end

  -- Copilot status check: only if API exists
  local ok_cp, copilot = pcall(require, "copilot")
  if ok_cp and copilot and type(copilot.status) == "table" then
    local s = copilot.status.data or {}
    local authed = (s.authenticated and "yes") or "no"
    local st = s.status or "unknown"
    vim.schedule(function()
      vim.notify(("Copilot init: status=%s auth=%s"):format(st, authed), vim.log.levels.INFO)
    end)
  else
  end

  -- Informative: report current buffer filetype
  local ft = vim.bo.filetype or ""
  vim.schedule(function()
    vim.notify(("Current buffer filetype: '%s'"):format(ft), vim.log.levels.INFO)
  end)
end

return {
  -- { import = "lazyvim.plugins.extras.ai.copilot" },

  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = false,
      },
      -- Liberal filetype defaults: enabled everywhere unless explicitly turned off
      filetypes = {
        ["*"] = true,
        ["dap-repl"] = false,
        ["TelescopePrompt"] = false,
        ["neo-tree-popup"] = false,
        -- Add disables if you want to limit Copilot:
        -- ["help"] = false,
        -- ["gitcommit"] = true,
        -- ["markdown"] = true,
      },
      -- If Node is not on PATH or you use a custom path, uncomment and set explicitly:
      -- copilot_node_command = "/usr/bin/node",
    },
    keys = {
      { "<leader>cI", "<cmd>Copilot toggle<cr>", desc = "Toggle IA (Copilot)" },
      { "<leader>ae", "<cmd>CopilotChatToggle<cr>", desc = "Toggle Chat (Copilot)" },
    },
    dependencies = {
      -- keep copilot-cmp as a dependency but DO NOT configure it here
      "zbirenbaum/copilot-cmp",
    },
    config = function(_, opts)
      -- 1) Initialize Copilot first
      require("copilot").setup(opts)

      -- 2) Then, initialize copilot-cmp immediately after Copilot is ready
      local ok_cmp_bridge, copilot_cmp = pcall(require, "copilot_cmp")
      if ok_cmp_bridge then
        copilot_cmp.setup({
          method = "getCompletionsCycling",
          formatters = {
            insert_text = require("copilot_cmp.format").remove_existing,
          },
        })
      else
        vim.schedule(function()
          vim.notify("copilot-cmp not found; Copilot CMP integration will be disabled", vim.log.levels.WARN)
        end)
      end

      -- 3) Finally, run runtime checks; schedule to allow init to complete
      vim.schedule(function()
        copilot_runtime_checks()
      end)
    end,
  },

  {
    "CopilotC-Nvim/CopilotChat.nvim",
    opts = function(_, opts)
      opts.context = vim.tbl_extend("force", opts.context or {}, {
        cwd_files = function()
          local cwd = vim.fn.getcwd()
          local files = {}
          local handle = io.popen(
            "find "
              .. cwd
              .. " -type f "
              .. " -not -path '*/.git/*'"
              .. " -not -path '*/node_modules/*'"
              .. " -not -path '*/.venv/*'"
              .. " -maxdepth 3"
          )
          if handle then
            for file in handle:lines() do
              table.insert(files, file)
            end
            handle:close()
          end
          return files
        end,
        open_buffers = function()
          local bufs = {}
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_option(buf, "modifiable") then
              local name = vim.api.nvim_buf_get_name(buf)
              if name ~= "" then
                table.insert(bufs, name)
              end
            end
          end
          return bufs
        end,
        git_status = function()
          local handle = io.popen("git status --porcelain")
          local status = {}
          if handle then
            for line in handle:lines() do
              table.insert(status, line)
            end
            handle:close()
          end
          return status
        end,
      })
      opts.window = {
        border = "rounded",
        width = 80,
        height = 20,
      }
      opts.keymaps = {
        close = "<Esc>",
        submit = "<C-CR>",
        next_context = "<Tab>",
        prev_context = "<S-Tab>",
      }
      return opts
    end,
    config = function(_, opts)
      require("CopilotChat").setup(opts)
      vim.api.nvim_create_autocmd("User", {
        pattern = "CopilotChatOpen",
        callback = function()
          require("CopilotChat.context").set_context("cwd_files")
        end,
      })
      vim.api.nvim_create_user_command("CopilotChatContextOpenBuffers", function()
        require("CopilotChat.context").set_context("open_buffers")
      end, {})
      vim.api.nvim_create_user_command("CopilotChatContextGitStatus", function()
        require("CopilotChat.context").set_context("git_status")
      end, {})
    end,
  },
}
