return {
  'nvim-treesitter/nvim-treesitter',
  dependencies = {},
  build = ':TSUpdate',
  opts = {
    auto_install = true,
  },
  config = function()
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
