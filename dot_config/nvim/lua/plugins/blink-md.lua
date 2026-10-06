-- blink.cmp: no automatic completion popup in markdown — candidates there come from
-- the buffer/path sources, not an LSP, so it fires on ordinary prose.
-- `<C-space>` still opens it on demand; other filetypes are untouched.
return {
  "saghen/blink.cmp",
  opts = {
    completion = {
      menu = {
        ---@param ctx blink.cmp.Context
        auto_show = function(ctx)
          return not vim.tbl_contains({ "markdown", "markdown.mdx" }, vim.bo[ctx.bufnr].filetype)
        end,
      },
      ghost_text = {
        enabled = function()
          if vim.tbl_contains({ "markdown", "markdown.mdx" }, vim.bo.filetype) then
            return false
          end
          return vim.g.ai_cmp and true or false -- LazyVim's gate, preserved elsewhere
        end,
      },
    },
  },
}
