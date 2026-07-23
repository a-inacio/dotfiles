# Dotfiles

Powered by [chezmoi](https://www.chezmoi.io).

## Bootstrap (fresh machine)

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/a-inacio/dotfiles/main/install.sh)"
```

Installs chezmoi + Neovim (≥ 0.11.2) + tmux's tpm, creates a local `~/.config/chezmoi/chezmoi.toml`
(once), then runs `chezmoi init --apply` — applying the dotfiles and fetching externals. Safe to
re-run: tool installs are idempotent and chezmoi won't silently overwrite locally-modified files.

## Requirements

### Font — MesloLGS NF (Nerd Font)

The prompt ([powerlevel10k](https://github.com/romkatv/powerlevel10k) + the Catppuccin theme) needs
a Nerd Font. Use **MesloLGS NF** from the canonical source:
<https://github.com/romkatv/powerlevel10k-media> — install all four variants
(`MesloLGS NF Regular/Bold/Italic/Bold Italic.ttf`).

**On WSL** the font is a *Windows-side* concern — the terminal is a Windows app, so a Linux font
install has no effect. Install the font in Windows and point the terminal at it:

1. Download the four `MesloLGS NF *.ttf` files (link above).
2. Install them in Windows (right-click → **Install**, per-user is fine — install all four).
3. Set the terminal font to `MesloLGS NF`, e.g. Windows Terminal `settings.json`:
   `profiles.defaults.font.face = "MesloLGS NF"`.

(`p10k configure` also offers to install the font, but the manual install above is the reliable path.)

## Notes

- **Neovim** uses [LazyVim](https://www.lazyvim.org) — plugins install on first `nvim` launch, pinned
  via `lazy-lock.json`.
- **tmux** — press `prefix + I` on first run to install plugins.
- **Day-to-day** (via the `cm*` aliases): edit a config, then `cmaa` to capture it into the source and
  `cmsave "msg"` to commit + push; `cmup` to sync another machine.
