-- LSP: nvim-lspconfig ships the server configs; we enable them with vim.lsp
-- (Neovim 0.11+ native API). Servers come from the manifest:
--   lua_ls -> lua-language-server,  tsgo -> @typescript/native-preview,
--   jsonls -> vscode-langservers-extracted,  yamlls -> yaml-language-server.
-- lazydev wires lua-language-server up for editing Neovim Lua config.
return {
  'neovim/nvim-lspconfig',
  priority = 90,
  dependencies = {
    {
      'folke/lazydev.nvim',
      ft = 'lua',
      opts = {
        library = {
          -- load luvit types when `vim.uv` is found
          { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        },
      },
    },
    'hrsh7th/cmp-nvim-lsp', -- so default_capabilities() is available here
  },
  config = function()
    -- tsgo/jsonls/yamlls are Node scripts; `node` is nvm-managed and only on
    -- PATH in an interactive shell. If nvim was launched without it, add the
    -- newest installed nvm node so those servers can still spawn.
    if vim.fn.executable('node') == 0 then
      local bins = vim.fn.glob(vim.env.HOME .. '/.nvm/versions/node/*/bin', false, true)
      if #bins > 0 then
        table.sort(bins) -- newest installed version last; any node runs the servers
        vim.env.PATH = bins[#bins] .. ':' .. vim.env.PATH
      end
    end

    -- Advertise nvim-cmp's completion capabilities to every server (the old
    -- config computed these but never applied them — so completion was degraded).
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    vim.lsp.config('*', { capabilities = capabilities })

    vim.lsp.enable({
      'lua_ls',
      'tsgo', -- @typescript/native-preview
      'jsonls',
      'yamlls',
    })

    group('LSP:', function(m)
      m.autocmd('LspAttach', {
        group = m.augroup('lsp_attach', { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          -- highlight other references of the symbol under the cursor
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

          -- buffer-local (Neovim 0.11 already maps K/grn/gra/grr/gri by default)
          m.normal('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration', { buffer = event.buf })
          m.normal('grd', vim.lsp.buf.definition, '[G]oto [d]efinition', { buffer = event.buf })
        end,
      })

      vim.diagnostic.config({
        float = { source = true, style = 'minimal', border = 'rounded' },
      })
    end)
  end,
}
