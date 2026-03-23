return {
	"folke/trouble.nvim",
  config = function ()
    require('trouble').setup({})

    group('Trouble', function (m)
      m.normal('<leader>tt', function ()
        vim.cmd('Trouble diagnostics toggle')
      end, 'Diagnostics')
    end)
  end
}
