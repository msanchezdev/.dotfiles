-- SurrealQL LSP: diagnostics, hover, completion, rename, go-to-def/refs, and
-- parser-accurate semantic-token highlighting.
--
-- Upstream now has the fixes (binary name, grammar branch, and "don't error on
-- nvim-treesitter main"), so we track surrealdb/surrealql-neovim directly.
--
-- The language server is a prebuilt binary the plugin downloads on first use
-- (no Rust toolchain); :SurrealQLInstall forces it.
--
-- treesitter stays off: surrealql parser registration uses nvim-treesitter's
-- master API, which our nvim-treesitter (main) doesn't expose — the plugin
-- skips it cleanly. The LSP's semantic tokens highlight .surql meanwhile.
return {
  'surrealdb/surrealql-neovim',
  ft = { 'surrealql' },
  main = 'surrealql',
  -- Map .surql/.surrealql to the surrealql filetype early, so opening one
  -- triggers the ft-based lazy load reliably.
  init = function()
    vim.filetype.add({ extension = { surql = 'surrealql', surrealql = 'surrealql' } })
  end,
  opts = {
    treesitter = { enable = false },
    lsp = { enable = true, auto_install = true },
  },
}
