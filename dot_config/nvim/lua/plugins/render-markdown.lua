-- render-markdown.nvim — in-editor rendering of Markdown (headings, code blocks,
-- tables, checkboxes, callouts, LaTeX). Deps (treesitter + mini.icons) are already
-- provided by LazyVim; listed here only to pin load order.
-- https://github.com/MeanderingProgrammer/render-markdown.nvim
return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter", -- parses the markdown
    "nvim-mini/mini.icons",            -- icon provider (LazyVim's default)
  },
  ft = { "markdown", "markdown.mdx" }, -- lazy-load on markdown buffers only
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    -- Wide tables: 'trimmed' subtracts the source's padding whitespace from the
    -- computed column width, so a table with long cells stays far narrower on
    -- screen than its raw text. Pairs with nowrap (see config/autocmds.lua).
    pipe_table = { cell = "trimmed", preset = "round" },
  },
}
