-- conform.nvim — formatting. External formatters are installed by the manifest
-- (stylua, biome, prettierd/prettier, shfmt; jq is bootstrap-managed; tsgo is
-- the TS LSP that backstops the JS/TS chain). Format-on-save, plus <leader>f to
-- format on demand. stop_after_first runs the first available formatter in the
-- list, so biome wins when present and prettier(d) is the fallback.
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>f",
      function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
      mode = "n",
      desc = "[F]ormat Buffer",
    },
  },
  opts = {
    formatters_by_ft = {
      json = { "jq" },
      lua = { "stylua" },
      javascript = { "biome", "prettierd", "prettier", "tsgo", stop_after_first = true },
      javascriptreact = { "biome", "prettierd", "prettier", "tsgo", stop_after_first = true },
      typescript = { "biome", "prettierd", "prettier", "tsgo", stop_after_first = true },
      typescriptreact = { "biome", "prettierd", "prettier", "tsgo", stop_after_first = true },
      sh = { "shfmt" },
      bash = { "shfmt" },
    },
    format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
  },
  config = function(_, opts)
    require("conform").setup(opts)
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
