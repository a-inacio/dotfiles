-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- gf in shell dotfiles: resolve the chezmoi/zsh path vars ($ZDOTDIR, $__zdir,
-- ${…:h}) RELATIVE TO THIS FILE's dir, so `gf` jumps to sibling fragments and
-- stays in whichever tree you opened (chezmoi source vs applied ~/.config). Neovim
-- already expands exported env vars + ~, but not shell locals ($__zdir) or zsh
-- modifiers (${…:h}); includeexpr is the built-in hook `gf` uses to transform the name.
_G.shell_dotfile_gf = function(fname)
  local dir, up = vim.fn.expand("%:p:h"), vim.fn.expand("%:p:h:h")
  fname = fname:gsub("%${__zdir:h}", up):gsub("%${ZDOTDIR:h}", up) -- ${…:h} -> parent dir
  fname = fname:gsub("%$__zdir", dir):gsub("%$ZDOTDIR", dir) --        $var    -> this dir
  return vim.fn.expand(fname) -- resolve any remaining $HOME / ~ / $VAR
end
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sh", "bash", "zsh" },
  callback = function()
    vim.opt_local.isfname:append({ "{", "}", ":" }) -- so gf grabs the whole ${…:h} token
    vim.opt_local.suffixesadd:append({ ".sh", ".zsh" })
    vim.opt_local.includeexpr = "v:lua.shell_dotfile_gf(v:fname)"
  end,
})
