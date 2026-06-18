-- neogit: a Magit-style git interface (<leader>gg).
return {
  'NeogitOrg/neogit',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'sindrets/diffview.nvim',
  },
  cmd = 'Neogit',
  keys = {
    { '<leader>gg', '<cmd>Neogit<cr>', desc = 'Neogit' },
  },
  opts = {
    enhanced_diff_hl = true, -- (was misspelled 'enchaned_diff_hl' in the old config)
  },
  init = function()
    vim.opt.fillchars:append({ diff = '/' })
  end,
}
