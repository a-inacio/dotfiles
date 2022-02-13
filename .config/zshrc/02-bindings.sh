# ------------------------------------------------------------------------------
# ⚠️  Option arrow keys will collide with Tmux current bindings
# ------------------------------------------------------------------------------
# ⌥ →
bindkey '^[^[[D' backward-word
# ⌥ ←
bindkey '^[^[[C' forward-word
# ⌥ ↑
bindkey '^[^[[A' vi-cmd-mode 
# ⌥ ↓ 
bindkey '^[^[[B' vi-put-before


# ------------------------------------------------------------------------------
# Vi mode tweaks
# ------------------------------------------------------------------------------
# Bring back ⌃ a / ⌃ e behavior from Emacs mode
bindkey "^A" vi-beginning-of-line
bindkey "^E" vi-end-of-line
# ⌃ ␣ alternative to ⎋
bindkey '^ ' vi-cmd-mode 
