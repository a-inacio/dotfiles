#!/usr/bin/env sh
# =============================================================================
#  install.sh — bootstrap the dependencies of my zsh config (antidote + plugins)
#
#  Remote (after your dotfiles are cloned, e.g. `yadm clone ...`):
#    sh -c "$(curl -fsSL https://raw.githubusercontent.com/a-inacio/dotfiles/main/.config/zsh/install.sh)"
#  Local:
#    ~/.config/zsh/install.sh
#
#  What it does (idempotent, non-interactive):
#    1. ensures `git` and `zsh` are installed (apt on Debian/Ubuntu, brew on macOS)
#    2. installs antidote into $ZDOTDIR/.antidote (matches what .zshrc expects)
#    3. pre-fetches every plugin in .zsh_plugins.txt and generates the static
#       .zsh_plugins.zsh, so your first shell start is instant.
#  Soft integrations (fzf / nvm / sdkman) are intentionally NOT installed here —
#  03-tools.sh guards them, so they're optional.
# =============================================================================
set -eu

ANTIDOTE_REPO="https://github.com/mattmc3/antidote.git"
# Resolve ZDOTDIR the same way ~/.zshenv does (this runs under sh, where it's unset).
ZDOTDIR="${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}"

info() { printf '\033[1;34m::\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$1" >&2; }
die()  { printf '\033[1;31mxx\033[0m %s\n' "$1" >&2; exit 1; }

# --- package-manager abstraction (apt / brew) --------------------------------
SUDO=""
if [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1; then SUDO="sudo"; fi

pkg_install() { # pkg_install <pkg>...
  if command -v brew >/dev/null 2>&1; then
    brew install "$@"
  elif command -v apt-get >/dev/null 2>&1; then
    $SUDO apt-get update -qq
    $SUDO apt-get install -y "$@"
  else
    die "No supported package manager (apt/brew) found — install '$*' manually."
  fi
}

ensure() { # ensure <command> [package]
  _cmd="$1"; _pkg="${2:-$1}"
  if command -v "$_cmd" >/dev/null 2>&1; then
    info "$_cmd already present"
  else
    info "installing $_pkg ..."
    pkg_install "$_pkg"
  fi
}

# --- 1. prerequisites --------------------------------------------------------
ensure git
ensure zsh

# --- 2. antidote -------------------------------------------------------------
if [ -d "$ZDOTDIR/.antidote/.git" ]; then
  info "antidote present ($ZDOTDIR/.antidote) — updating (best effort)"
  git -C "$ZDOTDIR/.antidote" pull --ff-only --quiet 2>/dev/null || warn "antidote update skipped"
else
  info "cloning antidote -> $ZDOTDIR/.antidote"
  mkdir -p "$ZDOTDIR"
  git clone --depth=1 "$ANTIDOTE_REPO" "$ZDOTDIR/.antidote"
fi

# --- 3. pre-fetch plugins from the manifest ----------------------------------
if [ -f "$ZDOTDIR/.zsh_plugins.txt" ]; then
  info "pre-fetching plugins + generating static bundle"
  export ZDOTDIR
  zsh -c 'source "$ZDOTDIR/.antidote/antidote.zsh"; antidote bundle <"$ZDOTDIR/.zsh_plugins.txt" >|"$ZDOTDIR/.zsh_plugins.zsh"'
  info "plugins cached under ${ANTIDOTE_HOME:-$HOME/.cache/antidote}"
else
  warn "no $ZDOTDIR/.zsh_plugins.txt (clone your dotfiles first) — skipping prefetch."
  warn "antidote will self-bootstrap plugins on your first zsh launch anyway."
fi

info "zsh config dependencies ready — start a new terminal or run: exec zsh"
