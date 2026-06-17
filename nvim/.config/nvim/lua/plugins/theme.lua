-- Colorscheme: monokai-v2 (with a slightly darker Normal background).
-- gruvbox is a nice alternative — add 'ellisonleao/gruvbox.nvim' and swap the
-- colorscheme line.
return {
  'khoido2003/monokai-v2.nvim',
  priority = 1000, -- load before other UI plugins so there's no flash
  lazy = false,
  config = function()
    vim.cmd.colorscheme('monokai-v2')
    vim.api.nvim_set_hl(0, 'Normal', { bg = '#29262a' })
  end,
}
