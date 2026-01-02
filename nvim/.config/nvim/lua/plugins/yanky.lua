return {
  "gbprod/yanky.nvim",
  event = "VeryLazy",
  opts = {
    highlight = {
      on_put = true,
      on_yank = true,
      timer = 200,
    },
  },
  keys = {
    { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put after (yanky)" },
    { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put before (yanky)" },
    { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Put after and move cursor (yanky)" },
    { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Put before and move cursor (yanky)" },
    { "<C-n>", "<Plug>(YankyCycleForward)", mode = { "n", "x" }, desc = "Next yank in ring" },
    { "<C-p>", "<Plug>(YankyCycleBackward)", mode = { "n", "x" }, desc = "Prev yank in ring" },
  },
}
