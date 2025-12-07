return {
  "barrett-ruth/live-server.nvim",
  build = "pnpm add -g live-server",
  cmd = { "LiveServerStart", "LiveServerStop" },
  config = function()
    require("live-server").setup({
      port = 0, -- Port number to use (0 for random port)
      host = "localhost", -- Specify the host (set to your desired value)
    })
  end,
}
