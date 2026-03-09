return {
  'nvim-telescope/telescope.nvim', version = '0.2.1',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    local telescope = require('telescope')
    local builtin = require('telescope.builtin')
    telescope.setup({
      defaults = {
        file_ignore_patterns = {
          'node_modules',
          '%.git',
        },
      },
      pickers = {
        find_files = {
          hidden = true,
          theme = 'dropdown',
        }
      }
    })

    group('Telescope', function(m)
      m.normal('<leader>sh', builtin.help_tags, '[S]earch [H]elp')
      m.normal('<leader>sk', builtin.keymaps, '[S]earch [K]eymaps')
      m.normal('<leader>sf', builtin.find_files, '[S]earch [F]iles')
      m.normal('<leader>ss', builtin.builtin, '[S]earch [S]elect Telescope')
      m.normal('<leader>sg', builtin.live_grep, '[S]earch by [G]rep')
      m.normal('<leader>s.', builtin.oldfiles, '[S]earch Recent Files')
      m.normal('<leader>sr', builtin.resume, '[S]earch [R]esume')
      m.normal('<leader><leader>', builtin.buffers, '[ ] Search Buffers')

      local find_config = function(path, opts)
        opts = opts or {}
        return function()
          return builtin.find_files(vim.tbl_deep_extend('force', {
            cwd = '~/.dotfiles/' .. (path or ''),
          }, opts))
        end
      end
      m.normal('<leader>scc', find_config('', {
        file_ignore_patterns = { '%.git/', '%-lock.json' }
      }), '[S]earch [C]onfig')
      m.normal('<leader>scn', find_config('nvim',{
        file_ignore_patterns = { '%-lock.json' }
      }), '[S]earch [C]onfig / [N]eovim')
      m.normal('<leader>sct', find_config('tmux'), '[S]earch [C]onfig / [T]mux')
      m.normal('<leader>scz', find_config('zsh'), '[S]earch [C]onfig / [Z]sh')
    end)
  end
}
