return {
  'hrsh7th/nvim-cmp',
  dependencies = {
    'hrsh7th/cmp-cmdline',
    -- 'folke/lazydev.nvim'
  },
  config = function()
    local cmp = require('cmp')

    cmp.setup({
      mapping = cmp.mapping.preset.insert({
        ['<C-Space>'] = cmp.mapping.complete(),
      }),
      sources = cmp.config.sources({
        { name = 'lazydev', group_index = 0 },
      })
    })
  end
}
