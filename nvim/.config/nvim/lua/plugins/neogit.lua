return {
  'NeogitOrg/neogit',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'sindrets/diffview.nvim',
  },
  config = function ()
    group('Neogit', function(m)
      m.normal('<leader>gg', '<cmd>Neogit<cr>')
    end)
  end
}
