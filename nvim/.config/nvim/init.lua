-- Minimal Neovim config — rebuild from scratch.
-- Previous full config: ~/nvim-config.full.bak
--   or: git show HEAD~1:nvim/.config/nvim/init.lua  (and the other files)

-- Options (also sets the leader keys, which must happen before lazy.nvim).
require('config.options')
-- Core keymaps; also defines the global group() helper used by plugin specs,
-- so load it before lazy.nvim sets up plugins.
require('config.keymap')

require('config.lazy')

require('config.autocmds')
