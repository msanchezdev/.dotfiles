-- SurrealQL LSP: diagnostics, hover, completion, rename, go-to-def/refs, and
-- parser-accurate semantic-token highlighting.
--
-- Using the fork branch until the upstream fix lands; once merged, switch to
--   'surrealdb/surrealql-neovim'  (drop branch).
--
-- The language server is a prebuilt binary the plugin downloads on first use
-- (linux x86_64/arm64, macOS arm64, Windows x86_64) — no Rust toolchain.
-- :SurrealQLInstall forces the download.
--
-- treesitter is OFF here: the LSP's semantic tokens already highlight. To add
-- the tree-sitter grammar too, install nvim-treesitter, set treesitter.enable
-- = true, and run :TSInstall surrealql.
return {
  'msanchezdev/surrealql-neovim',
  branch = 'fix/lsp-binary-name-and-docs',
  ft = { 'surrealql' },
  main = 'surrealql',
  -- Map .surql/.surrealql to the surrealql filetype early, so opening one
  -- triggers the ft-based lazy load reliably.
  init = function()
    vim.filetype.add({ extension = { surql = 'surrealql', surrealql = 'surrealql' } })
  end,
  opts = {
    treesitter = { enable = true },
    lsp = { enable = true, auto_install = true },
  },
}
