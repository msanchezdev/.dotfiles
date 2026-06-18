-- harpoon: pin a handful of files and jump between them instantly.
return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  event = 'VeryLazy',
  config = function()
    local harpoon = require('harpoon')
    harpoon:setup({})

    -- telescope picker over the harpoon list
    local conf = require('telescope.config').values
    local function toggle_telescope(harpoon_files)
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end
      require('telescope.pickers')
        .new({}, {
          prompt_title = 'Harpoon',
          finder = require('telescope.finders').new_table({ results = file_paths }),
          previewer = conf.file_previewer({}),
          sorter = conf.generic_sorter({}),
        })
        :find()
    end
    vim.keymap.set('n', '<C-e>', function()
      toggle_telescope(harpoon:list())
    end, { desc = 'Harpoon: open window' })

    group('Harpoon', function(m)
      local function harpoon_select(n)
        return function() harpoon:list():select(n) end
      end
      local function harpoon_replace(n)
        return function() harpoon:list():replace_at(n) end
      end
      for i = 1, 8 do
        m.normal('<leader>' .. i, harpoon_select(i), 'Switch to file #' .. i)
        m.normal('<leader>q' .. i, harpoon_replace(i), 'Replace file #' .. i)
      end

      m.normal('<leader>qq', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, 'Toggle quick menu')
      m.normal('<leader>qc', function()
        harpoon:list():clear()
      end, 'Clear all')
    end)
  end,
}
