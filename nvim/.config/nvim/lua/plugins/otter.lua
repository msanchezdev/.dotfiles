-- Embedded LSP for surql`...` template literals in JS/TS: otter.nvim finds the
-- injected SurrealQL regions (via the tree-sitter injection query shipped by
-- surrealql-neovim), extracts them into a hidden `surrealql` buffer, attaches
-- the SurrealQL LSP to it, and proxies completion/hover/diagnostics back.
return {
  'jmbuhr/otter.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  ft = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
  config = function()
    require('otter').setup({
      -- Map the injected language name -> file extension, so the otter buffer
      -- gets filetype `surrealql` and the surql LSP attaches.
      extensions = { surrealql = 'surql' },
    })

    local fts = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' }
    -- (languages, completion, diagnostics); diagnostics off to avoid noise from
    -- ${...} interpolations landing in the extracted query.
    local function activate() require('otter').activate({ 'surrealql' }, true, false) end

    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('otter.surql', { clear = true }),
      pattern = fts,
      callback = activate,
    })
    -- The FileType event that ft-lazy-loaded us already fired, so activate the
    -- buffer we loaded on too.
    if vim.tbl_contains(fts, vim.bo.filetype) then activate() end
  end,
}
