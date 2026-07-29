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
  opts = {},
}
