-- which-key: popup that shows available keybindings as you type a prefix.
return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  opts = {},
  keys = {
    {
      '<leader>?',
      function()
        require('which-key').show({ global = false })
      end,
      desc = 'Which Key: Buffer Keymaps',
    },
  },
}
