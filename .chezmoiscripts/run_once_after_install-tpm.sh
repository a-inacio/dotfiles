#!/usr/bin/env sh
# Install tmux's plugin manager (tpm) once. tmux can't self-bootstrap it; after this,
# plugins install with `prefix + I`. (zsh/antidote and nvim/lazy self-bootstrap on
# first launch, so they need no script here.)
set -eu
TPM="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM" ] && command -v git >/dev/null 2>&1; then
  echo ":: installing tmux plugin manager (tpm)"
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM"
fi
