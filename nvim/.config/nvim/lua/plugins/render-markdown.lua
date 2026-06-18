-- Markdown: in-buffer rendering (render-markdown) + browser preview
-- (markdown-preview). render-markdown needs the markdown/markdown_inline
-- tree-sitter parsers (ensured in plugins/treesitter.lua).
return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons', -- icons (already pulled by telescope)
    },
    ft = { 'markdown' },
    opts = {},
  },
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    build = 'cd app && bun install',
    init = function()
      vim.g.mkdp_filetypes = { 'markdown' }
    end,
    ft = { 'markdown' },
  },
}
