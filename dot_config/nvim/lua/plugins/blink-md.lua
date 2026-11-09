-- blink.cmp in markdown: no automatic popup on ordinary prose (buffer/path candidates fire on every
-- word) EXCEPT inside an open `[[` wikilink, where markdown-oxide offers note/heading completions.
-- `<C-space>` still opens it on demand anywhere; other filetypes are untouched.
return {
  "saghen/blink.cmp",
  opts = {
    completion = {
      menu = {
        ---@param ctx blink.cmp.Context
        auto_show = function(ctx)
          if not vim.tbl_contains({ "markdown", "markdown.mdx" }, vim.bo[ctx.bufnr].filetype) then
            return true
          end
          local before = ctx.line:sub(1, ctx.cursor[2])
          return before:match("%[%[[^%]]*$") ~= nil -- typing inside an unclosed [[
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
