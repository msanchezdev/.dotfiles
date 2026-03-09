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

    cmp.setup({
      window = {
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm(),
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

    -- cmp.setup.cmdline({ ':q' }, {
    --   mapping = cmp.mapping.preset.cmdline({}),
    --   sources = cmp.config.sources({
    --     { name = "path" }
    --   })
    -- })

    cmp.setup.cmdline({ '/', '?' }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = "buffer" }
      })
    })
  end
}
