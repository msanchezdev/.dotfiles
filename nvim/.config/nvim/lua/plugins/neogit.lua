return {
  'NeogitOrg/neogit',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'sindrets/diffview.nvim',
  },
  opts = {
    enchaned_diff_hl = true,
  },
  config = function()
    vim.opt.fillchars:append({ diff = '/' })

    group('Neogit', function(m)
      m.normal('<leader>gg', '<cmd>Neogit<cr>')
    end)
  end
}
