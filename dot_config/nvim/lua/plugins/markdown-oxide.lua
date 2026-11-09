-- markdown-oxide — the PKM language server for the second-brain vaults (~/work-personal, ~/work).
-- Wikilinks, backlinks, completion, aliases, unresolved-link diagnostics, Obsidian-compatible.
-- Chosen over obsidian.nvim after a spike (workmode 00c, 2026-11-09): obsidian.nvim runs ripgrep without -L,
-- so it can't see file-symlinked notes (base memories) or follow relative markdown links.
-- On top of it, lua/mdnotes.lua adds obsidian-style behaviour (create-on-missing, deduped jumps, grouped
-- backlinks, smart <CR>). Folder excludes live in ~/.config/moxide/settings.toml.
return {
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "markdown-oxide" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- ONE link engine: marksman was auto-enabled by mason-lspconfig just for being installed in mason
        marksman = { enabled = false },
        markdown_oxide = {
          -- vault markers FIRST: lspconfig's default puts .git first, so a nested repo inside a vault
          -- (e.g. a .tmp/ clone) would become the root and shrink the index to that repo.
          root_markers = { ".obsidian", ".moxide.toml", ".git" },
          -- oxide adds NEW files to its index only on didChangeWatchedFiles (src/main.rs)
          capabilities = { workspace = { didChangeWatchedFiles = { dynamicRegistration = true } } },
        },
      },
    },
    init = function()
      -- Bind gd/gr/gR/<CR> for markdown_oxide buffers through Snacks.keymap (the same mechanism LazyVim uses
      -- for its global LSP keys). Snacks applies the NEWEST registration first, so registering on the first
      -- oxide attach, after LazyVim's, makes these win deterministically. A plain buffer map would be
      -- clobbered: Snacks re-applies its maps (debounced 100 ms) on every client attach.
      local registered = false
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("mdnotes_keys", { clear = true }),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if registered or not client or client.name ~= "markdown_oxide" then return end
          registered = true
          local notes = require("mdnotes")
          local function map(lhs, rhs, desc)
            Snacks.keymap.set("n", lhs, rhs, { lsp = { name = "markdown_oxide" }, desc = desc })
          end
          map("gd", notes.follow, "Follow link (dedupe; create if missing)")
          map("gr", notes.backlinks, "Backlinks, one row per file")
          map("gR", function() Snacks.picker.lsp_references() end, "References, every occurrence")
          map("<CR>", notes.smart_cr, "Follow link / toggle checkbox")
        end,
      })
    end,
  },
}
