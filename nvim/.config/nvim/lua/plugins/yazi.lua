-- yazi.nvim: open the yazi file manager inside neovim (uses the yazi CLI from
-- the manifest). Separate from the `y` shell function (cd-on-quit in zsh).
---@type LazySpec
return {
  'mikavilpas/yazi.nvim',
  version = '*', -- latest stable
  event = 'VeryLazy',
  dependencies = {
    { 'nvim-lua/plenary.nvim', lazy = true },
  },
  keys = {
    { '<leader>-', mode = { 'n', 'v' }, '<cmd>Yazi<cr>', desc = 'Yazi: open at current file' },
    { '<leader>cw', '<cmd>Yazi cwd<cr>', desc = "Yazi: open in nvim's cwd" },
    { '<c-up>', '<cmd>Yazi toggle<cr>', desc = 'Yazi: resume last session' },
  },
  ---@type YaziConfig | {}
  opts = {
    open_for_directories = true, -- use yazi instead of netrw for directories
    keymaps = {
      show_help = '<f1>',
    },
  },
}
