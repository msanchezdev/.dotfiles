-- undotree: visualize and navigate the undo history (:UndotreeToggle).
return {
  'mbbill/undotree',
  keys = {
    { '<leader>u', '<cmd>UndotreeToggle<cr>', desc = 'Undotree: Toggle' },
  },
}
