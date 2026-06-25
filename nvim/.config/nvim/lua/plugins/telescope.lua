-- Fuzzy finder. Uses ripgrep (live_grep) and fd (find_files) when present —
-- both are in the manifest. Your previous telescope config (dropdown theme,
-- many LSP pickers) is in ~/nvim-config.full.bak/lua/plugins/telescope.lua.
return {
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x',
  event = 'VimEnter',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    local telescope = require('telescope')
    telescope.setup({
      defaults = {
        -- nvim-treesitter `main` (the rewrite) removed the classic
        -- parsers.ft_to_lang / configs API that telescope's preview highlighter
        -- still calls, so its treesitter path errors ("attempt to call field
        -- 'ft_to_lang' (a nil value)"). Disable TS in previews — they fall back
        -- to vim's :syntax highlighting; editing buffers keep full TS highlights.
        preview = { treesitter = false },
      },
    })

    local builtin = require('telescope.builtin')
    local map = function(keys, fn, desc)
      vim.keymap.set('n', keys, fn, { desc = 'Telescope: ' .. desc })
    end
    map('<leader>sf', builtin.find_files, 'find files')
    map('<leader>sg', builtin.live_grep, 'live grep')
    map('<leader>sh', builtin.help_tags, 'help tags')
    map('<leader>sk', builtin.keymaps, 'keymaps')
    map('<leader>sd', builtin.diagnostics, 'diagnostics')
    map('<leader>sr', builtin.resume, 'resume last search')
    map('<leader>s.', builtin.oldfiles, 'recent files')
    map('<leader><leader>', builtin.buffers, 'buffers')
  end,
}
