return {
  {
    "folke/snacks.nvim",
    -- merge your settings into LazyVim’s defaults
    opts = function(_, opts)
      opts.dashboard = vim.tbl_deep_extend("force", opts.dashboard or {}, {
        pane_gap = 20,
        autokeys = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",

        preset = {
          keys = {
            {
              { key = "n", hidden = true, action = ":ene | startinsert" },
              { key = "f", hidden = true, action = ":lua Snacks.dashboard.pick('files')" },
              { key = "r", hidden = true, action = ":lua Snacks.dashboard.pick('oldfiles')" },
              { key = "g", hidden = true, action = ":lua Snacks.dashboard.pick('live_grep')" },
              { key = "s", hidden = true, section = "session" },
              { key = "L", hidden = true, action = ":Lazy", enabled = package.loaded.lazy ~= nil },
              { key = "q", hidden = true, action = ":qa", enabled = package.loaded.lazy ~= nil },
            },
          },
          width = 100,
          header = [[
                                                
                                                
    I'm just a chill guy who uses Neovim, btw.  
                                                
                                                
                          @@@ @@@@              
                          @  @@@ @              
                       @@@@ @@@@@               
                @@@@@@@   @@   @@               
        @@@@@@@      @@@ @@@    @               
      @@@@@@@@        @@  @@@    @              
      @@@@@@@@                   @              
      @@@@@@@@                   @              
      @@@@@@@@                   @              
       @@@@@@@              @   @              
         @@@@         @@@@@@@    @              
             @@@@@     @@@@     @@              
                 @@@        @@@@  @             
                @    @@@@@@@       @            
                @@             @    @           
                 @               @  @           
                @              @    @           
                 @@@@@@@@   @@@@    @           
                  @  @@@@@@     @@@@            
                  @     @@@       @@            
                   @     @        @@            
                   @     @        @@            
                   @     @        @             
                   @     @    @@   @            
                  @@@@@@@@ @      @@            
                 @    @@@@@@@@@@@@@@            
                 @      @@      @@@             
                  @@@@@   @@@@@@@               
]],
        },

        formats = {
          header = { align = "center" },
          key = { "" },
          file = function(item)
            return {
              { item.key, hl = "key" },
              { " " },
              { item.file:sub(2):match("^(.*[/])"), hl = "NonText" },
              { item.file:match("([^/]+)$"), hl = "Normal" },
            }
          end,
          icon = { "" },
        },

        sections = {
          {
            pane = 1,
            { section = "header", padding = 1, height = 200 },
          },
          {
            pane = 2,
            padding = 5,
            height = 50,
            {
              { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
              { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
              { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
              {
                text = {
                  { "n ", hl = "key" },
                  { "New file", hl = "Normal" },
                  { "", width = 12 },
                  { "g ", hl = "key" },
                  { "Grep text", hl = "Normal" },
                },
              },
              { text = "", padding = 1 },
              {
                text = {
                  { "f ", hl = "key" },
                  { "Find file", hl = "Normal" },
                  { "", width = 11 },
                  { "s ", hl = "key" },
                  { "Reload session", hl = "Normal" },
                },
              },
              { text = "", padding = 1 },
              {
                text = {
                  { "r ", hl = "key" },
                  { "Recent files", hl = "Normal" },
                  { "", width = 8 },
                  { "L ", hl = "key" },
                  { "Lazy", hl = "Normal" },
                },
              },
              {
                icon = "",
                title = "Local Weather! GO OUTSIDE!",
                padding = { 2, 2, 2, 2 },
                gap = 5,
              },
              { section = "terminal", cmd = "curl -s 'wttr.in/?0'", gap = 5 },
            },
          },
        },
      })

      opts.explorer = vim.tbl_deep_extend("force", opts.explorer or {}, {
        enabled = true,
        hidden = true,
      })

      opts.picker = vim.tbl_deep_extend("force", opts.picker or {}, {
        sources = {
          files = { hidden = true },
          grep = { hidden = true },
          explorer = { hidden = true },
        },
      })

      opts.bigfile = { enabled = true }
      opts.indent = { enabled = true }
      opts.input = { enabled = true }
      opts.lazygit = { enabled = true }
      opts.notifier = { enabled = false }
      opts.quickfile = { enabled = true }
      opts.scroll = { enabled = true }
      opts.statuscolumn = { enabled = true }
      opts.words = { enabled = true }

      return opts
    end,

    config = function(_, opts)
      require("snacks").setup(opts)

      vim.api.nvim_set_hl(0, "SnacksDashboardKey", { fg = "#5ceef6" })
      vim.api.nvim_set_hl(0, "SnacksDashboardTitle", { fg = "#c49aee" })
    end,
  },
}
