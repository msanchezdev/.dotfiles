return {
  "neovim/nvim-lspconfig",
  dependencies = {
    {
      'folke/lazydev.nvim',
      opts = {
        library = {
          -- Load luvit types when the `vim.uv` word is found
          { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        }
      }
    }
  },
  config = function()
    vim.lsp.enable({
      'lua_ls',
      'elixirls',
      'tsgo',
    })
  end
}
