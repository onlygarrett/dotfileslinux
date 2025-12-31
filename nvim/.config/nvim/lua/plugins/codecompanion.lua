-- AI-powered code assistant with native Ollama integration
-- Replaces avante.nvim for more stable, turn-based AI interactions
return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "hrsh7th/nvim-cmp", -- For chat buffer completion
  },

  opts = {
    -- Use Ollama adapter for all interaction types
    strategies = {
      chat = { adapter = "ollama" },
      inline = { adapter = "ollama" },
      cmd = { adapter = "ollama" },
    },

    -- Configure native Ollama adapter
    adapters = {
      ollama = function()
        return require("codecompanion.adapters").extend("ollama", {
          env = {
            url = "http://127.0.0.1:11434",
          },
          schema = {
            model = {
              default = "hf.co/unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q4_K_M",
            },
            num_ctx = {
              default = 16000, -- Large context window
            },
            num_predict = {
              default = -1, -- No limit on output tokens
            },
          },
          parameters = {
            temperature = 0.7,
            top_p = 0.9,
            repeat_penalty = 1.2,
          },
        })
      end,

      -- Custom SearXNG adapter for privacy-focused web search
      searxng = function()
        local fmt = string.format
        local log = require("codecompanion.utils.log")

        return {
          name = "searxng",
          formatted_name = "SearXNG",
          roles = {
            llm = "assistant",
            user = "user",
          },
          opts = {
            method = "GET", -- Use GET request for SearXNG
          },
          url = "http://localhost:8080/search",
          env = {}, -- No API key needed!
          headers = {
            ["Accept"] = "application/json",
          },
          schema = {
            model = {
              default = "searxng",
            },
          },
          handlers = {},
          methods = {
            tools = {
              web_search = {
                ---Setup the adapter for the web_search tool
                ---@param self CodeCompanion.HTTPAdapter
                ---@param opts table Tool options
                ---@param data table The data from the LLM's tool call
                ---@return nil
                setup = function(self, opts, data)
                  opts = opts or {}

                  -- URL encode function
                  local function url_encode(str)
                    if str then
                      str = string.gsub(str, "\n", "\r\n")
                      str = string.gsub(str, "([^%w %-%_%.%~])", function(c)
                        return string.format("%%%02X", string.byte(c))
                      end)
                      str = string.gsub(str, " ", "+")
                    end
                    return str
                  end

                  -- Build query parameters for GET request
                  local params = {
                    q = url_encode(data.query),
                    format = "json",
                    categories = opts.categories or "general",
                    engines = opts.engines or nil,
                    language = opts.language or "en",
                    safesearch = tostring(opts.safesearch or 1),
                    time_range = opts.time_range or nil,
                    pageno = tostring(opts.pageno or 1),
                  }

                  -- Construct URL with query parameters
                  local query_parts = {}
                  for k, v in pairs(params) do
                    if v ~= nil then
                      table.insert(query_parts, fmt("%s=%s", k, v))
                    end
                  end

                  self.url = fmt("http://localhost:8080/search?%s", table.concat(query_parts, "&"))
                  log:debug("[SearXNG Adapter] Request URL: %s", self.url)

                  -- GET request doesn't need a body, but CodeCompanion expects set_body handler
                  self.handlers.set_body = function()
                    return {} -- Return empty table for GET requests
                  end
                end,

                ---Process the output from the web_search tool
                ---@param self CodeCompanion.HTTPAdapter
                ---@param data table The data returned from the search
                ---@return table{status: string, content: string}|nil
                callback = function(self, data)
                  local ok, body = pcall(vim.json.decode, data.body)
                  if not ok then
                    log:error("[SearXNG Adapter] Could not parse JSON response")
                    return {
                      status = "error",
                      content = "Could not parse JSON response from SearXNG",
                    }
                  end

                  if data.status ~= 200 then
                    log:error("[SearXNG Adapter] Error %s - %s", data.status, vim.inspect(body))
                    return {
                      status = "error",
                      content = fmt("SearXNG returned error %s", data.status),
                    }
                  end

                  -- Process SearXNG results
                  if not body.results or #body.results == 0 then
                    log:warn("[SearXNG Adapter] No results found for query")
                    return {
                      status = "error",
                      content = "No search results found",
                    }
                  end

                  -- Transform SearXNG results to CodeCompanion format
                  -- Use title as fallback if content is empty
                  local output = vim
                    .iter(body.results)
                    :map(function(result)
                      local content = result.content or result.title or ""
                      return {
                        content = content,
                        title = result.title or "No title",
                        url = result.url or "",
                      }
                    end)
                    :totable()

                  return {
                    status = "success",
                    content = output,
                  }
                end,
              },
            },
          },
        }
      end,
    },

    -- Configure tools with SearXNG
    -- NOTE: Uses locally-hosted SearXNG instance (http://localhost:8080)
    -- Available engines depend on your SearXNG configuration
    -- To check available engines: curl "http://localhost:8080/search?q=test&format=json" | jq '.results[].engine | unique'
    interactions = {
      chat = {
        tools = {
          web_search = {
            opts = {
              adapter = "searxng", -- Use our custom SearXNG adapter instead of Tavily
              opts = {
                -- SearXNG-specific options
                max_results = 5, -- Return top 5 results
                engines = "brave,startpage", -- Use available engines (adjust based on your SearXNG config)
                categories = "general",
                language = "en",
                safesearch = 1, -- Moderate filtering
              },
            },
          },
        },
      },
    },

    -- Display settings
    display = {
      chat = {
        window = {
          layout = "vertical", -- Side-by-side with code
          width = 0.45,
          height = 0.8,
        },
        render_headers = true,
        show_settings = false,
        show_token_count = true,
      },
      inline = {
        diff = {
          enabled = true,
          provider = "default", -- Use native diff
        },
      },
    },

    -- Logging for troubleshooting
    opts = {
      log_level = "DEBUG", -- Debug mode for SearXNG integration testing
    },
  },

  config = function(_, opts)
    require("codecompanion").setup(opts)

    -- Keymaps
    local map = vim.keymap.set

    -- Action palette (main entry point)
    map({ "n", "v" }, "<C-a>", "<cmd>CodeCompanionActions<cr>", {
      desc = "CodeCompanion Actions",
      noremap = true,
      silent = true,
    })

    -- Toggle chat buffer (using <leader>ca instead of <LocalLeader>)
    map({ "n", "v" }, "<leader>ca", "<cmd>CodeCompanionChat Toggle<cr>", {
      desc = "Toggle Chat",
      noremap = true,
      silent = true,
    })

    -- Add visual selection to chat
    map("v", "ga", "<cmd>CodeCompanionChat Add<cr>", {
      desc = "Add to Chat",
      noremap = true,
      silent = true,
    })

    -- Quick inline prompt with visual selection
    map("v", "<leader>ci", "<cmd>CodeCompanion<cr>", {
      desc = "Inline Prompt",
      noremap = true,
      silent = true,
    })

    -- Additional useful commands
    map("n", "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", {
      desc = "Toggle Chat",
    })

    map("n", "<leader>cq", function()
      vim.cmd("CodeCompanionChat " .. vim.fn.input("Quick Chat: "))
    end, {
      desc = "Quick Chat",
    })

    -- Close chat
    map("n", "<leader>cx", "<cmd>CodeCompanionChat Close<cr>", {
      desc = "Close Chat",
    })

    -- Expand 'cc' into 'CodeCompanion' in command line for quick access
    vim.cmd([[cab cc CodeCompanion]])

    -- Register which-key group
    local ok, remaps = pcall(require, "config.remaps")
    if ok and remaps.map_virtual then
      remaps.map_virtual({
        { "<leader>c", group = "codecompanion", icon = { icon = "󰚩", hl = "Constant" } },
      })
    end
  end,

  -- Lazy loading configuration
  keys = {
    { "<C-a>", mode = { "n", "v" } },
    { "<leader>ca", mode = { "n", "v" } },
    { "<leader>cc", mode = "n" },
    { "<leader>ci", mode = "v" },
    { "<leader>cq", mode = "n" },
    { "<leader>cx", mode = "n" },
    { "ga", mode = "v" },
  },
  cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
}
