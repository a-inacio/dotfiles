-- workmode.nvim loader — the plugin itself is developed + NDA-gated in workmode-core.
-- Thin bridge for now (deploy/install mechanism TBD): dofile the dev clone; no-op if absent.
local ok, spec = pcall(dofile, vim.fn.expand("~/src/workmode-core/nvim/workmode.lua"))
return ok and spec or {}
