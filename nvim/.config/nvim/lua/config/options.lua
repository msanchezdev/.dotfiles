vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

-- vim.opt.guicursor = ""
vim.opt.colorcolumn = "80,120"
vim.opt.signcolumn = "yes"

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.mouse = 'a'

-- vim.opt.clipboard = "unnamedplus"

vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.updatetime = 50
vim.opt.scrolloff = 8

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv('HOME') .. '/.vim/undodir'
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

-- vim.g.netrw_preview = 1
-- vim.g.netrw_liststyle = 3
-- vim.g.netrw_winsize   = 30
--
