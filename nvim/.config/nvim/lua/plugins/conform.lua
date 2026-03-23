return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			json = { "jq" },
			lua = { "stylua" },
			javascript = { "prettierd", "prettier", "tsgo", stop_after_first = true },
			javascriptreact = { "prettierd", "prettier", "tsgo", stop_after_first = true },
			typescript = { "prettierd", "prettier", "tsgo", stop_after_first = true },
			typescriptreact = { "prettierd", "prettier", "tsgo", stop_after_first = true },
		},
	},
	config = function(_, opts)
		local conform = require("conform")
		conform.setup(opts)
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

		group("Format", function(m)
			m.normal("<leader>f", conform.format, "[F]ormat Buffer")
		end)
	end,
}
