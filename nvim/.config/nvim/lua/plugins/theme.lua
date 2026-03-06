return {
  {
    'ellisonleao/gruvbox.nvim',
    dependencies = {
      { 'khoido2003/monokai-v2.nvim' },
    },
    config = function()
      -- vim.cmd.colorscheme("gruvbox")
      vim.cmd.colorscheme("monokai-v2")
    end
  },
}
