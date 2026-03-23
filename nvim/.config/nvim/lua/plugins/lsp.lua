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
      'expert',
      'tsgo',
      'yamlls',
    })

    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    group("LSP:", function(m)
      m.autocmd('LspAttach', {
        group = m.augroup('lsp_attach', { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            m.autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })

            m.autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end

          m.normal('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          m.normal('grd', vim.lsp.buf.definition, '[G]oto [d]efinition')
        end
      })

      vim.diagnostic.config({
        float = {
          source = true,
          style = "minimal",
          border = "rounded",
        }
      })
    end)
  end
}
