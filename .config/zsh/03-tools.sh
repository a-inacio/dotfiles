# Tool / version-manager init + completions. Sourced (via 00-all.sh) AFTER
# oh-my-zsh has run compinit, so completion registration works.

# bash-style completions — needed by `complete -C` (e.g. terragrunt below).
autoload -U +X bashcompinit && bashcompinit

# fzf — keybindings + completion
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
(( $+commands[fzf] )) && source <(fzf --zsh)

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# autojump (Homebrew / macOS; guarded, no-op on WSL)
[ -f /opt/homebrew/etc/profile.d/autojump.sh ] && . /opt/homebrew/etc/profile.d/autojump.sh

# terragrunt completion
(( $+commands[terragrunt] )) && complete -o nospace -C /usr/local/bin/terragrunt terragrunt

# work — workmode project launcher: shell integration (tab-completion + `work cd`)
(( $+commands[work] )) && source <(work completions zsh)
