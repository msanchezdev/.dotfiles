-- DISABLED reference from your previous config.
-- To re-enable: uncomment the spec below and delete the trailing 'return {}'.
-- (Note: old keymaps used custom group()/m.* helpers that no longer exist —
--  adapt them to vim.keymap.set when reviving.)
--
-- -- SurrealQL: LSP, tree-sitter highlighting, and surql`...` injection in JS/TS.
-- -- Dogfooding the local checkout; once published, swap `dir` for the repo
-- -- (e.g. 'surrealdb/surrealql-nvim'). The JS/TS host parsers it injects into
-- -- are ensured in plugins/treesitter.lua.
-- return {
--   dir = '/home/msanchezdev/.local/src/surrealql-nvim',
--   build = function() require('surrealql').install() end,
--   config = function()
--     require('surrealql').setup()
--   end,
-- }

return {}
