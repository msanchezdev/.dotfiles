-- nvim-treesitter (main branch — the rewrite, for Neovim 0.11+). Installs a
-- base parser set and starts native tree-sitter highlighting per filetype.
-- Parsers compile locally, so a C compiler is needed (build-essential on Linux
-- is in the manifest; macOS uses the Xcode CLT).
return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,           -- main branch does not support lazy-loading
  build = ':TSUpdate',
  config = function()
    local nts = require('nvim-treesitter')
    local ensure = {
      'lua', 'vim', 'vimdoc', 'bash', 'json', 'yaml', 'toml',
      'markdown', 'markdown_inline', 'javascript', 'typescript', 'tsx', 'html', 'css',
    }
    local installed = nts.get_installed()
    local missing = vim.tbl_filter(function(l)
      return not vim.tbl_contains(installed, l)
    end, ensure)
    if #missing > 0 then nts.install(missing) end

    -- Start tree-sitter highlighting for any buffer whose language has a parser.
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('treesitter.highlight', { clear = true }),
      callback = function() pcall(vim.treesitter.start) end,
    })
  end,
}
