return {
  "nvim-mini/mini.comment",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    options = {
      -- Reuse treesitter commentstring when available
      custom_commentstring = function()
        local ok, ts = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
        if ok and ts and ts.calculate_commentstring then
          local commentstring = ts.calculate_commentstring()
          if commentstring then
            return commentstring
          end
        end
        return vim.bo.commentstring
      end,
    },
  },
}
