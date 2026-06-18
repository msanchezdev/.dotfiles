-- Auto-sourced on surrealql buffers. Start tree-sitter highlighting (+ folding,
-- experimental indentation); the parser is registered/installed by the
-- surrealql plugin. The LSP's semantic tokens refine these colors on attach.
-- (commentstring/tabstop are set by the plugin's filetype config.)
pcall(vim.treesitter.start)
vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
