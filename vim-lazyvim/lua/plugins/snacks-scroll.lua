-- Disable snacks.nvim smooth scrolling so scrolling is instant like stock Vim.
return {
  {
    "folke/snacks.nvim",
    opts = {
      scroll = { enabled = false },
    },
  },
}
