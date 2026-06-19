-- nvim-treesitter (master branch — the classic API). configs.setup enables
-- highlighting + indentation for installed parsers and auto-installs parsers
-- for opened filetypes. Parsers compile locally (needs a C compiler — Linux
-- build-essential is in the manifest; macOS uses the Xcode CLT).
--
-- On master (not main) because master's highlight engine renders tagged-template
-- injections (e.g. surql`...` in JS/TS); native injection on the main branch +
-- Neovim 0.12 does not build the injected tree.
return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'master',
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter.configs').setup({
      ensure_installed = {
        'lua', 'vim', 'vimdoc', 'bash', 'json', 'yaml', 'toml',
        'markdown', 'markdown_inline', 'javascript', 'typescript', 'tsx', 'html', 'css',
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
