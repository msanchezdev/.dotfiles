-- SurrealQL: LSP, tree-sitter highlighting, and surql`...` injection in JS/TS.
-- Dogfooding the local checkout; once published, swap `dir` for the repo
-- (e.g. 'surrealdb/surrealql-nvim'). The JS/TS host parsers it injects into
-- are ensured in plugins/treesitter.lua.
return {
  dir = '/home/msanchezdev/.local/src/surrealql-nvim',
  build = function() require('surrealql').install() end,
  config = function()
    require('surrealql').setup()
  end,
}
