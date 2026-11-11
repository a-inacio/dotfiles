-- workmode.nvim — editor UX for workmode workspaces (a-inacio/workmode-nvim, a private repo).
-- Source: the dev clone at ~/src/workmode-nvim when present (edits are live after a restart), else the
-- latest v0.x release over the personal SSH alias. A machine with neither gets nothing — no clone error
-- at every startup. The plugin itself is dormant outside a workmode workspace.
local dev = vim.fn.expand("~/src/workmode-nvim")

local function has_personal_alias()
  local ok, lines = pcall(vim.fn.readfile, vim.fn.expand("~/.ssh/config"))
  if not ok then
    return false
  end
  for _, l in ipairs(lines) do
    if l:match("^%s*Host%s.*github%.com%-personal") then
      return true
    end
  end
  return false
end

local src
if vim.uv.fs_stat(dev .. "/lua/workmode/init.lua") then
  src = { dir = dev }
elseif has_personal_alias() then
  src = { url = "git@github.com-personal:a-inacio/workmode-nvim.git", version = "^0" }
else
  return {}
end

local function wm()
  local ok, m = pcall(require, "workmode")
  return ok and m or nil
end

return {
  vim.tbl_extend("force", { name = "workmode.nvim", lazy = true }, src),
  {
    "folke/snacks.nvim",
    dependencies = { "workmode.nvim" },
    init = function()
      local m = wm()
      if m then
        m.init()
      end
    end,
    opts = function(plugin, opts)
      local m = wm()
      if m then
        m.snacks_opts(plugin, opts)
      end
    end,
  },
}
