-- Minimal Neovim config — rebuild from scratch.
-- Previous full config: ~/nvim-config.full.bak
--   or: git show HEAD~1:nvim/.config/nvim/init.lua  (and the other files)

-- Leader keys must be set before lazy.nvim loads.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Add options/keymaps/autocmds here (or split into lua/config/* and require them).

require('config.lazy')
