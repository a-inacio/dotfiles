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

## Claude Code status line

`~/.claude/statusline.sh` (needs `jq` + a Nerd Font):

```text
Opus 5.5 · myproj@dotfiles        ctx ███░░░░░░░  31% 󰔟 · 5h  23% 2h14m · wk  41% 3d4h
```

- **ctx**: context-window use, plus an hourglass for the prompt cache (green → orange → red =
  warm → about to expire → cold, when the next request re-writes the whole prefix).
- **5h / wk**: subscription plan usage, i.e. the 5-hour and weekly rate-limit windows, % used and
  time to reset. Claude Code sends these only to Pro/Max subscribers, after the first response.
  Without them the slot shows the gateway `spend` limit, else the local `~$` session estimate.
- Location is the workmode `project@domain` when `workmode` is installed, else the path.

Everything comes from Claude Code's stdin: no network calls. `chezmoi apply` sets `statusLine` in
`~/.claude/settings.json` (that key only; the rest is kept) unless something else already owns it:
a different `statusLine` command is kept, and a symlinked `settings.json` is left alone. Machines
with the private overlay keep their own `settings.json` and status line.
Tune with `CLAUDE_STATUSLINE_MARGIN` / `_BAR_WIDTH` / `_PROJECT_MAX`. For alignment, point
`statusLine.command` at `~/.claude/statusline.sh --ruler` once to find the clipped margin.

## Notes

- **Neovim** uses [LazyVim](https://www.lazyvim.org) — plugins install on first `nvim` launch, pinned
  via `lazy-lock.json`.
- **tmux** — press `prefix + I` on first run to install plugins.
- **Day-to-day** (via the `cm*` aliases): edit a config, then `cmaa` to capture it into the source and
  `cmSave "msg"` to commit + push; `cmp` to sync another machine.
