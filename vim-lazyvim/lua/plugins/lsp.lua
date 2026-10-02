-- Extra language servers. Each one is installed by mason and set up by lspconfig.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {},
      },
    },
  },
}
