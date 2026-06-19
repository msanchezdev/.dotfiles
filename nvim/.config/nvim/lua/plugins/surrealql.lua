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
  -- Load at startup (NOT ft-lazy). The surql`...` JS/TS injection lives in the
  -- plugin's after/queries/{javascript,typescript,tsx}/injections.scm, which
  -- must be on the runtimepath BEFORE the treesitter highlighter first reads
  -- the 'typescript'/'javascript' injections query — that query is memoized for
  -- the whole session, so if the plugin loads even a tick late (ft-lazy loses
  -- this race to the highlighter's redraw), the surrealql injection is missing
  -- permanently. Loading eagerly puts the queries on rtp up front.
  lazy = false,
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

    -- setup() just registered the parser; ensure it's installed (nvim-treesitter
    -- master API). Needs a C compiler — in the manifest.
    pcall(function()
      require('nvim-treesitter.install').ensure_installed('surrealql')
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
