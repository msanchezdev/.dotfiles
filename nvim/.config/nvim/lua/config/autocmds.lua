vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    -- vim.highlight was renamed to vim.hl in Neovim 0.11; support both.
    local hl = vim.hl or vim.highlight
    hl.on_yank()
  end
})
