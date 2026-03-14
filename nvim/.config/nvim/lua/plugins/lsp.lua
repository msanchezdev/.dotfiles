return {
  'neovim/nvim-lspconfig',
  priority = 90,
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
    require('lazydev').setup({})
    vim.lsp.enable({
      'lua_ls',
      'elixirls',
      'tsgo',
      'yamlls',
    })

    group('LSP', function(m)
      m.normal('<leader>f', function()
        vim.lsp.buf.format()
      end, 'Format Buffer')
    end)
  end
}
