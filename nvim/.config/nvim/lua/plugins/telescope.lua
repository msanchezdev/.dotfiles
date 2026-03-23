return {
  'nvim-telescope/telescope.nvim', version = '0.2.1',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    'nvim-tree/nvim-web-devicons',
  },
  event = 'VimEnter',
  config = function()
    local telescope = require('telescope')
    local builtin = require('telescope.builtin')
    local themes = require('telescope.themes')

    telescope.setup({
      defaults = themes.get_dropdown({
        file_ignore_patterns = {
          'node_modules',
          '%.git',
        },
        winblend = 10,
        layout_config = {
          width = function (_, cols, _)
            if cols > 120 + 4 then
              return 120
            else
              return math.floor(cols * 0.9 + 0.5)
            end
          end,
          height = 0.75,
        },
        layout_strategy = "vertical"
      }),
      pickers = {
        find_files = {
          hidden = true,
        },
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
      m.normal('<leader>sd', builtin.diagnostics, '[S]earch [D]iagnostics')
      m.normal('<leader>sld', builtin.lsp_definitions, '[S]earch [D]efinitions')
      m.normal('<leader>sltd', builtin.lsp_type_definitions, '[S]earch [T]ype [D]efinitions')
      m.normal('<leader>slr', builtin.lsp_references, '[S]earch [R]eferences')
      m.normal('<leader>slws', builtin.lsp_workspace_symbols, '[S]earch [W]orkspace [S]ymbols')
      m.normal('<leader>slds', builtin.lsp_document_symbols, '[S]earch [D]ocument [S]ymbols')
      m.normal('<leader>sli', builtin.lsp_implementations, '[S]earch [I]mplementations')
      m.normal('<leader>slci', builtin.lsp_incoming_calls, '[S]earch [C]alls / [I]ncoming')
      m.normal('<leader>slco', builtin.lsp_outgoing_calls, '[S]earch [C]alls / [O]utgoing')

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
