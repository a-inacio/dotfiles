## Enable Vi mode
bindkey -v

# ------------------------------------------------------------------------------
# Vi mode tweaks
# ------------------------------------------------------------------------------
# Bring back ⌃ a / ⌃ e behavior from Emacs mode
bindkey "^A" vi-beginning-of-line
bindkey "^E" vi-end-of-line
# ⌃ ␣ alternative to ⎋
bindkey '^ ' vi-cmd-mode

# ------------------------------------------------------------------------------
# ⌃ g -> edit the current command line in $EDITOR (nvim); save+quit runs it.
# Same key Claude Code uses. Overrides the default ^G (list-expand, niche).
# autoload + `zle -N` guard load order so the bindkey can't run before the
# widget is registered.
# ------------------------------------------------------------------------------
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^G' edit-command-line
