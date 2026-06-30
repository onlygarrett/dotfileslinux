-- FTerm plugin configuration
return {
  {"numToStr/FTerm.nvim",
    vim.keymap.set('n', '<A-i>', '<CMD>lua require("FTerm").toggle()<CR>'),
    vim.keymap.set('t', '<A-i>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')
  },
}
