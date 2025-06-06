# Powerlevel10k instant prompt. 
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Enable Vi mode
bindkey -v

export GOPATH=$HOME/go

export PATH=$HOME/.sbin:${PATH}
export PATH=$GOPATH/bin:${PATH}
export PATH=./node_modules/.bin:${PATH}

export ZSH="$HOME/.oh-my-zsh"

# powerlevel10k is a bit glitchy on the embeded 
if [[ $__INTELLIJ_COMMAND_HISTFILE__ ]]; then
  ZSH_THEME="robbyrussell"
else
  ZSH_THEME="powerlevel10k/powerlevel10k"
fi

#plugins=(git)

source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Custom configs
source ~/.config/zshrc/00-all.sh

# Initialize completion
compinit

export VISUAL=nvim
export EDITOR=nvim

# Use english (https://unix.stackexchange.com/questions/87745/what-does-lc-all-c-do)
export LC_ALL=en_US.UTF-8

#[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

source <(fzf --zsh)

eval $(thefuck --alias)
eval "$(zoxide init zsh)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# SpaceVim - python support for neovim
export PYTHON3_HOST_PROG=`which python3`
export PYTHON_HOST_PROG=`which python`

export VIM_DOTFILES_DIR="$HOME/.config/vim"

# sdkman claims needing to be added to the end 🥴
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"


export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="/usr/local/sbin:$PATH"

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/terragrunt terragrunt
