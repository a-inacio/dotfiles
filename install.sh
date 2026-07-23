#!/usr/bin/env sh
# =============================================================================
#  install.sh — one-shot bootstrap for a ready-to-use environment (chezmoi-based)
#
#  Personal/home machine:
#    sh -c "$(curl -fsSL https://raw.githubusercontent.com/a-inacio/dotfiles/main/install.sh)"
#  Work machine: run dotfiles-private/install.sh instead — it sets the private
#    overlay URL into the local chezmoi config, then calls THIS script.
#
#  Lives at the repo ROOT and is .chezmoiignore'd, so it never lands in $HOME.
#  Idempotent + non-interactive. Supports Debian/Ubuntu (apt) and macOS (brew).
# =============================================================================
set -eu

DOTFILES="a-inacio/dotfiles"          # public source repo (chezmoi expands to https)
NVIM_STABLE="0.12.4"                   # installed if nvim is missing or < 0.11.2
CHEZMOI_CFG="${XDG_CONFIG_HOME:-$HOME/.config}/chezmoi/chezmoi.toml"

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

# --- 3b. tmux plugin manager (tpm) — tmux can't self-bootstrap it ------------
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  info "installing tmux plugin manager (tpm)"
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# --- 4. local-only chezmoi config (create ONCE; never overwrite) -------------
# Default = no private overlay (home machine). A work machine's private install.sh
# writes privateRepo here BEFORE calling this script; the guard below preserves it.
if [ ! -f "$CHEZMOI_CFG" ]; then
  info "creating default chezmoi config (no private overlay)"
  mkdir -p "$(dirname "$CHEZMOI_CFG")"
  cat > "$CHEZMOI_CFG" <<'EOF'
# Local-only chezmoi config (NEVER committed). Machine-specific.
[data]
    # Private overlay repo URL. EMPTY = personal/home machine (no private overlay).
    # A work machine's dotfiles-private/install.sh sets this before bootstrap.
    privateRepo = ""
EOF
  chmod 600 "$CHEZMOI_CFG"
else
  info "chezmoi config already present — keeping it"
fi

# --- 5. clone the source + apply everything ----------------------------------
info "applying dotfiles (chezmoi init --apply $DOTFILES)"
"$CHEZMOI" init --apply "$DOTFILES"

info "done — open a new terminal. (nvim: plugins install on first launch; tmux: prefix + I)"
