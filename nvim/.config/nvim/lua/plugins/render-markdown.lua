return {
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && yarn install",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    ft = { "markdown" },
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreview<CR>", desc = "Preview Markdown", ft = "markdown" },
      { "<leader>ms", "<cmd>MarkdownPreviewStop<CR>", desc = "Stop Preview", ft = "markdown" },
      { "<leader>mt", "<cmd>MarkdownPreviewToggle<CR>", desc = "Toggle Preview", ft = "markdown" },
    },
    init = function()
      vim.g.mkdp_auto_close = 0
      vim.g.mkdp_echo_preview_url = 1

      vim.cmd([[
        function! OpenMarkdownPreview(url)
          execute "silent ! firefox --new-window " . a:url . " &"
        endfunction
      ]])
      vim.g.mkdp_browserfunc = "OpenMarkdownPreview"
    end,
  },
}
