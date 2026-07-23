# ============================================================================
#  ~/.config/zsh/.zshrc   (ZDOTDIR set by ~/.zshenv)
#  Plugin manager: antidote (static/performance load). No oh-my-zsh framework —
#  only its lib is pulled in via getantidote/use-omz (see .zsh_plugins.txt).
# ============================================================================

# Powerlevel10k instant prompt — keep near the top. Anything needing console
# input (passwords, [y/n]) must go ABOVE this block.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# PATH + environment — before plugins so tools are visible.
source $ZDOTDIR/00-env.sh

# Catppuccin p10k flavour/theme — set BEFORE the theme plugin loads.
zstyle ':catppuccin:p10k' 'theme'   'rainbow'
zstyle ':catppuccin:p10k' 'flavour' 'mocha'

# --- antidote: static/performance load (https://antidote.sh/install) ---
# Bootstrap-clone antidote on a fresh machine.
[[ -d $ZDOTDIR/.antidote ]] || \
  git clone --depth=1 https://github.com/mattmc3/antidote.git $ZDOTDIR/.antidote

zsh_plugins=$ZDOTDIR/.zsh_plugins
[[ -f ${zsh_plugins}.txt ]] || touch ${zsh_plugins}.txt
fpath=($ZDOTDIR/.antidote/functions $fpath)
autoload -Uz antidote
# Regenerate the static bundle only when the manifest (.txt) is newer.
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  antidote bundle <${zsh_plugins}.txt >|${zsh_plugins}.zsh
fi
source ${zsh_plugins}.zsh

# Custom config — aliases, keybindings, tools, private extras (after plugins).
source $ZDOTDIR/00-all.sh
