-- Auto-sourced on surrealql buffers. Start tree-sitter highlighting (+ folding,
-- experimental indentation); the parser is registered/installed by the
-- surrealql plugin. The LSP's semantic tokens refine these colors on attach.
-- (commentstring/tabstop are set by the plugin's filetype config.)
--
-- This ftplugin and lazy's `ft`-load of surrealql-neovim both fire on the same
-- FileType event. If we call treesitter.start() now, the highlighter's first
-- `query.get('surrealql', 'highlights')` runs *before* lazy has put the plugin's
-- queries/ dir on the runtimepath, gets nil, and Neovim memoizes that nil for
-- the rest of the session — parser loads, but no colors. Defer one tick so the
-- queries are on rtp before the first (and cache-defining) query.get.
local buf = vim.api.nvim_get_current_buf()
vim.schedule(function()
  if vim.api.nvim_buf_is_valid(buf) then
    pcall(vim.treesitter.start, buf)
  end
end)
vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
