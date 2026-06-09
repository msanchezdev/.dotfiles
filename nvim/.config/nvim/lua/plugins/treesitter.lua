return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  config = function()
    local nts = require('nvim-treesitter')

    -- Parsers we rely on. nvim-treesitter installs the parser *and* its
    -- queries into stdpath('data')/site, resolving inherits (ecma/jsx). This
    -- guard makes it idempotent: a no-op once present, and only compiles on a
    -- fresh machine. The JS/TS parsers are the hosts that surrealql-nvim
    -- injects surql`...` template literals into.
    local ensure = { 'typescript', 'tsx', 'javascript' }
    local installed = nts.get_installed()
    local missing = vim.tbl_filter(function(lang)
      return not vim.tbl_contains(installed, lang)
    end, ensure)
    if #missing > 0 then
      nts.install(missing)
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("EnableTreesitterHighlighting", { clear = true }),
      desc = "Try to enable tree-sitter syntax highlighting",
      pattern = "*", -- run on *all* filetypes
      callback = function()
        pcall(function() vim.treesitter.start() end)
      end,
    })
  end
}
