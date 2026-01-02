-- https://github.com/lewis6991/gitsigns.nvim
require("gitsigns").setup({
  signs = {
    add          = { text = "+" },
    change       = { text = "|" },
    delete       = { text = "x" },
    topdelete    = { text = "^" },
    changedelete = { text = "~" },
    untracked    = { text = "!" },
  },
  signs_staged = {
    add          = { text = "SA" },
    change       = { text = "SC" },
    delete       = { text = "SX" },
    topdelete    = { text = "S^" },
    changedelete = { text = "S~" },
    untracked    = { text = "SU" },
  },
})
