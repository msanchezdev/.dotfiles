return {
  'nvim-mini/mini.nvim',
  config = function()
    require('mini.ai').setup()
    require('mini.diff').setup()
    require('mini.surround').setup()

    local mini_indscope = require('mini.indentscope')
    mini_indscope.setup({
      draw = {
        animation = mini_indscope.gen_animation.none()
      }
    })

    local minijump = require('mini.jump2d')
    minijump.setup({
      spotter = minijump.builtin_opts.word_start.spotter,
      view = {
        n_steps_ahead = 2
      }
    })

    require('mini.statusline').setup()
  end
}
