# Dotfiles

Powered by [Yadm](https://yadm.io/docs/install).

## Requirements

### Font — MesloLGS NF (Nerd Font)

The prompt ([powerlevel10k](https://github.com/romkatv/powerlevel10k) + the Catppuccin
theme) needs a Nerd Font. Use **MesloLGS NF** from the canonical source:
<https://github.com/romkatv/powerlevel10k-media> — install all four variants
(`MesloLGS NF Regular/Bold/Italic/Bold Italic.ttf`).

**On WSL** the font is a *Windows-side* concern — the terminal is a Windows app, so a
Linux font install has no effect. Install the font in Windows and point the terminal at it:

1. Download the four `MesloLGS NF *.ttf` files (link above).
2. Install them in Windows (right-click → **Install**, per-user is fine — install all four).
3. Set the terminal font to `MesloLGS NF`, e.g. Windows Terminal `settings.json`:
   `profiles.defaults.font.face = "MesloLGS NF"`.

(`p10k configure` also offers to install the font, but the manual install above is the reliable path.)

## Setup

### Shell (zsh)

Install the zsh plugin dependencies (antidote + plugins):

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/a-inacio/dotfiles/main/.config/zsh/install.sh)"
```

### Neovim

After opening Neovim for the first time:

- Run `:GoInstallBinaries`.
- Exit, then in `~/.cache/vimfiles/repos/github.com/neoclide/coc.nvim` run `yarn install`.

### Tmux

First run requires installing the plugins:

- `prefix I` (⚠️ capital I).
