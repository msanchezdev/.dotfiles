return {
  'hrsh7th/nvim-cmp',
  dependencies = {
    'hrsh7th/cmp-cmdline',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-nvim-lsp',
    -- 'folke/lazydev.nvim'
  },
  config = function()
    local cmp = require('cmp')
    local cmp_select = { behavior = cmp.SelectBehavior.Select }

    cmp.setup({
      mapping = cmp.mapping.preset.insert({
        ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
        ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm(),
        ['<Tab>'] = cmp.mapping.confirm(),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
      }, {
        { name = 'lazydev', group_index = 0 },
      })
    })

    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = "cmdline" },
      })
    })

    cmp.setup.cmdline({ '/', '?' }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = "buffer" }
      })
    })
  end
}
