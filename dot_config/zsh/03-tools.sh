# Tool / version-manager init + completions. Sourced (via 00-all.sh) AFTER the
# antidote plugin block, so every completion fpath change is already in place.

# Completion system: run compinit NOW (after all plugin fpath changes) so the
# fzf/work/terragrunt completion scripts below — which call `compdef`/`complete`
# immediately — actually register. ez-compinit (antidote) DEFERS compinit to the
# first prompt via precmd hooks; left deferred it also runs a SECOND time AFTER
# this file and rebuilds _comps from fpath, silently wiping the runtime `compdef`s
# we add here (that regressed `work` completion + broke Tab → files, leaving only
# autosuggest's → accept). So run compinit now, then cancel the deferred precmd
# hooks (its wrapper is meant to, but the removal doesn't stick). Falls back to a
# plain compinit when ez-compinit isn't loaded.
(( ${+functions[compinit]} )) || autoload -Uz compinit
compinit
autoload -Uz add-zsh-hook
add-zsh-hook -d precmd run-compinit 2>/dev/null                    # ez-compinit deferred compinit
add-zsh-hook -d precmd ensure-compinit-during-precmd 2>/dev/null   # ez-compinit safety re-run

# bash-style completions — needed by `complete -C` (e.g. terragrunt below).
autoload -U +X bashcompinit && bashcompinit

# fzf — keybindings + completion
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# `fzf --zsh` needs fzf >= 0.48; older builds (e.g. Ubuntu 22.04 apt = 0.29) print
# "unknown option: --zsh" and trip p10k's instant-prompt warning. Fall back silently
# to the distro's legacy scripts when present.
if (( $+commands[fzf] )); then
  if _fzf_init="$(fzf --zsh 2>/dev/null)"; then
    eval "$_fzf_init"
  else
    for _f in /usr/share/doc/fzf/examples/{key-bindings,completion}.zsh; do
      [ -f "$_f" ] && source "$_f"
    done
  fi
  unset _fzf_init _f
fi

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
