-- Auto-sourced on surrealql buffers. Highlighting and indentation come from
-- nvim-treesitter (master) globally via configs.setup; the LSP's semantic
-- tokens refine the colors on attach. (commentstring/tabstop are set by the
-- plugin's filetype config.) Here we just enable tree-sitter folding, open.
vim.wo[0][0].foldmethod = 'expr'
vim.wo[0][0].foldexpr = 'nvim_treesitter#foldexpr()'
vim.wo[0][0].foldlevel = 99
