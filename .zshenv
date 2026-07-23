# Point zsh at ~/.config/zsh for the rest of its startup files (ZDOTDIR).
# This is the ONLY zsh file that must live in $HOME.
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
[[ -f $ZDOTDIR/.zshenv ]] && source $ZDOTDIR/.zshenv
