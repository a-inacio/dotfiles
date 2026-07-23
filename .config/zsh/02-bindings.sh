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
