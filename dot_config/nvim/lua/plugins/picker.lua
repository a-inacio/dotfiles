-- Fuzzy finder: follow symlinks in file search.
--
-- LazyVim's default picker here is snacks.picker (not telescope), so this configures the snacks `files`
-- source. `follow = true` descends into symlinked dirs; BOTH <leader>ff (root) and <leader>fF (cwd) route
-- through this same source (also <leader><space>), so one setting covers them while preserving the
-- root/cwd distinction. Uses ripgrep under the hood (`rg -L`).
--
-- Caveat: following symlinks means rg errors ("Command failed" flash) only if the search tree contains a
-- symlink LOOP — e.g. two workmode projects with reciprocal Dependencies/ links, or searching from $HOME.
-- Normal repos and loop-free workmode projects work cleanly.
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        files = { follow = true },
      },
    },
  },
}
