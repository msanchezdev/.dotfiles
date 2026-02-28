vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

vim.opt.colorcolumn = "80,120"
vim.opt.signcolumn = "yes"

-- Line numbering
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true

-- Searching
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Indentation
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

-- Window splitting
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Mouse
vim.opt.mouse = 'a'

-- Clipboard
-- vim.opt.clipboard = "unnamedplus"

-- Render whitespace
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Undo/Redo
vim.opt.undodir = os.getenv('HOME') .. '/.vim/undodir'
vim.opt.undofile = true

-- Search
vim.opt.hlsearch = false
vim.opt.incsearch = true
