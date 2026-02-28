return {
  'nvim-treesitter/nvim-treesitter',
  dependencies = {},
  build = ':TSUpdate',
  opts = {
    ensure_installed = {
      'elixir'
    }
  }
}
