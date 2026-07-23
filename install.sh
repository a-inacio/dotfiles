#!/usr/bin/env sh
# =============================================================================
#  install.sh — one-shot bootstrap for a ready-to-use environment (chezmoi-based)
#
#  Personal/home machine:
#    sh -c "$(curl -fsSL https://raw.githubusercontent.com/a-inacio/dotfiles/main/install.sh)"
#  Work machine: run dotfiles-private/install.sh instead — it exports the private
#    overlay URL ($DOTFILES_PRIVATE_REPO), then calls THIS script.
#
#  Lives at the repo ROOT and is .chezmoiignore'd, so it never lands in $HOME.
#  Idempotent + non-interactive. Supports Debian/Ubuntu (apt) and macOS (brew).
# =============================================================================
set -eu

# Start from a known-good directory — a deleted/inaccessible CWD breaks chezmoi (getwd).
cd "$HOME" 2>/dev/null || cd /

DOTFILES="a-inacio/dotfiles"          # public source repo (chezmoi expands to https)
NVIM_STABLE="0.12.4"                   # installed if nvim is missing or < 0.11.2

info() { printf '\033[1;34m::\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$1" >&2; }
die()  { printf '\033[1;31mxx\033[0m %s\n' "$1" >&2; exit 1; }

SUDO=""; [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1 && SUDO="sudo"
pkg_install() {
  if command -v brew >/dev/null 2>&1; then brew install "$@"
  elif command -v apt-get >/dev/null 2>&1; then $SUDO apt-get update -qq && $SUDO apt-get install -y "$@"
  else die "no supported package manager (apt/brew) — install '$*' manually"; fi
}
ensure() { command -v "$1" >/dev/null 2>&1 && info "$1 present" || { info "installing ${2:-$1}"; pkg_install "${2:-$1}"; }; }

# --- 1. prerequisites --------------------------------------------------------
ensure git
ensure zsh
ensure curl

# --- 2. chezmoi (root-free) --------------------------------------------------
if ! command -v chezmoi >/dev/null 2>&1 && [ ! -x "$HOME/.local/bin/chezmoi" ]; then
  info "installing chezmoi -> ~/.local/bin"
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
fi
CHEZMOI="$(command -v chezmoi || echo "$HOME/.local/bin/chezmoi")"

# --- 3. Neovim >= 0.11.2 (root-free) — LazyVim requires it -------------------
need_nvim() {
  command -v nvim >/dev/null 2>&1 || return 0
  nvim --headless -c 'if has("nvim-0.11.2")|qa|else|cq|endif' >/dev/null 2>&1 && return 1 || return 0
}
if need_nvim; then
  if command -v brew >/dev/null 2>&1; then
    info "installing neovim via brew"; brew install neovim
  else
    case "$(uname -m)" in x86_64) A=x86_64;; aarch64|arm64) A=arm64;; *) die "unsupported arch for nvim tarball";; esac
    info "installing Neovim ${NVIM_STABLE} (root-free -> ~/.local/nvim)"
    rm -rf "$HOME/.local/nvim" "$HOME/.local/nvim-linux-$A"
    curl -fsSL "https://github.com/neovim/neovim/releases/download/v${NVIM_STABLE}/nvim-linux-${A}.tar.gz" | tar -xz -C "$HOME/.local"
    mv "$HOME/.local/nvim-linux-$A" "$HOME/.local/nvim"
    mkdir -p "$HOME/.local/bin"; ln -sf "$HOME/.local/nvim/bin/nvim" "$HOME/.local/bin/nvim"
  fi
else
  info "neovim present + >= 0.11.2"
fi

# --- 4. clone source + apply -------------------------------------------------
# (tmux self-bootstraps tpm + its plugins on first launch — see .tmux.conf)
# `chezmoi init` generates ~/.config/chezmoi/chezmoi.toml from the repo's
# .chezmoi.toml.tmpl (privateRepo = $DOTFILES_PRIVATE_REPO if the private layer
# exported it, else the existing value, else empty), then applies + fetches externals.
info "applying dotfiles (chezmoi init --apply $DOTFILES)"
"$CHEZMOI" init --apply "$DOTFILES"

info "done — open a new terminal. (nvim: plugins install on first launch; tmux: prefix + I)"
