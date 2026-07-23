# Location-independent: source siblings relative to THIS file's dir (= $ZDOTDIR).
__zdir=${0:A:h}
source $__zdir/01-alias-core.sh
source $__zdir/01-alias-development.sh
source $__zdir/01-alias-tools.sh
source $__zdir/02-bindings.sh
source $__zdir/03-tools.sh

# Private overlay — the NDA repo cloned to ~/.config/dotfiles-private (if present).
# Sourced LAST so its fragments can override/extend the public config; a no-op when
# the clone is absent (non-work machines). (N) = nullglob.
__dpriv="$HOME/.config/dotfiles-private/zsh"
if [ -d "$__dpriv" ]; then
  for f in "$__dpriv"/*.sh(N); do
    [ -f "$f" ] && source "$f"
  done
fi
