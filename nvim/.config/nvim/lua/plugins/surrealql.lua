-- SurrealQL for .surql/.surrealql: tree-sitter highlighting (offline, instant)
-- + language server (semantic tokens, diagnostics, hover, completion, refs,
-- rename, …). Both stack — see surrealdb/surrealql-lsp-neovim-setup.md.
--
-- The plugin (PR #10) registers the grammar on nvim-treesitter main *and*
-- master and ships matching queries; the LSP binary auto-downloads on first
-- .surql open (cargo fallback if no prebuilt binary). Highlighting itself is
-- started per-buffer in ftplugin/surrealql.lua.
return {
  'surrealdb/surrealql-neovim',
  -- Also load for JS/TS filetypes so the plugin's after/queries/*/injections.scm
  -- land on the runtimepath there — that's what highlights surql`...` template
  -- literals. With only 'surrealql' the plugin never loads in those buffers and
  -- the injection silently does nothing (the README's snippet has this gap).
  ft = { 'surrealql', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  -- Map the extensions early so the ft-based lazy load triggers on open.
  init = function()
    vim.filetype.add({ extension = { surql = 'surrealql', surrealql = 'surrealql' } })
  end,
  opts = {
    treesitter = { enable = true }, -- register the parser (default true)
    lsp = { enable = true },        -- download + attach the server (auto_install defaults true)
  },
  config = function(_, opts)
    require('surrealql').setup(opts) -- registers the parser + sets up the LSP

    -- setup() just registered the parser; install it once (async). Needs the
    -- tree-sitter CLI + a C compiler — both are in the manifest.
    pcall(function()
      local nts = require('nvim-treesitter')
      if not vim.tbl_contains(nts.get_installed(), 'surrealql') then
        nts.install({ 'surrealql' })
      end
    end)

    -- Make the LSP's definition/builtin semantic-token modifiers pop
    -- (re-applied on colorscheme change).
    local function hl()
      vim.api.nvim_set_hl(0, '@lsp.typemod.function.defaultLibrary', { link = 'Comment' }) -- greyed stdlib
      vim.api.nvim_set_hl(0, '@lsp.mod.declaration', { bold = true })                       -- bold defs
    end
    hl()
    vim.api.nvim_create_autocmd('ColorScheme', { callback = hl })
  end,
}
