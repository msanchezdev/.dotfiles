return {
  'nvim-telescope/telescope.nvim', version = '0.2.1',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
  },
  config = function()
    local telescope = require('telescope')
    local builtin = require('telescope.builtin')

    group('Telescope', function(m)
      m.normal('<leader>sh', builtin.help_tags, '[S]earch [H]elp')
      m.normal('<leader>sk', builtin.keymaps, '[S]earch [K]eymaps')
      m.normal('<leader>sf', builtin.find_files, '[S]earch [F]iles')
      m.normal('<leader>ss', builtin.builtin, '[S]earch [S]elect Telescope')
      m.normal('<leader>sg', builtin.live_grep, '[S]earch by [G]rep')
      m.normal('<leader>s.', builtin.oldfiles, '[S]earch Recent Files')
      m.normal('<leader>sr', builtin.resume, '[S]earch [R]esume')
      m.normal('<leader><leader>', builtin.buffers, '[ ] Search Buffers')
      m.normal('<leader>sn', function()
        builtin.find_files({
          cwd = vim.fn.stdpath("config")
        })
      end, '[S]earch [N]eovim Config')
    end)
  end
}
