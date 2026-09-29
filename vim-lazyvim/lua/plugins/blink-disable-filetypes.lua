-- Disable the blink.cmp autocompletion menu for plain-text-ish filetypes.
return {
  {
    "saghen/blink.cmp",
    opts = {
      enabled = function()
        return not vim.tbl_contains({ "text", "markdown", "csv" }, vim.bo.filetype)
      end,
    },
  },
}
