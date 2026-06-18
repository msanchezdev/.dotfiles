-- trouble: a pretty list for diagnostics, symbols, quickfix, LSP refs, etc.
-- (Diagnostics fill in once LSP servers are added; symbols/qf work now.)
return {
  'folke/trouble.nvim',
  cmd = 'Trouble',
  opts = {},
  keys = {
    { '<leader>tt', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Trouble: Diagnostics' },
    { '<leader>ts', '<cmd>Trouble symbols toggle<cr>', desc = 'Trouble: Symbols' },
  },
}
