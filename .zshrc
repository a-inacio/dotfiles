# Powerlevel10k instant prompt.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# PATH + environment — before oh-my-zsh so tools are visible to it.
source ~/.config/zshrc/00-env.sh

export ZSH="$HOME/.oh-my-zsh"

# powerlevel10k is a bit glitchy on the embeded
if [[ $__INTELLIJ_COMMAND_HISTFILE__ ]]; then
  ZSH_THEME="robbyrussell"
else
  ZSH_THEME="powerlevel10k/powerlevel10k"
fi

source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Custom config — tools, aliases, keybindings, private extras (after oh-my-zsh).
source ~/.config/zshrc/00-all.sh
