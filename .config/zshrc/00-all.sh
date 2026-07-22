source ~/.config/zshrc/01-alias-core.sh
source ~/.config/zshrc/01-alias-development.sh
source ~/.config/zshrc/01-alias-tools.sh
source ~/.config/zshrc/02-bindings.sh
source ~/.config/zshrc/03-tools.sh

__priv="$HOME/.config/zshrc/private"

if [ -d "$__priv" ]; then
  # 1) Loose machine-local snippets: private/NN-*.sh (top level; NN- prefix = order).
  #    (N) = nullglob, so an empty dir yields no entries instead of a literal glob.
  for script in "$__priv"/*.sh(N); do
    [ -f "$script" ] && source "$script"
  done

  # 2) Cloned private repos: private/<repo>/*.plugin.zsh (oh-my-zsh plugin convention).
  #    Only the entrypoint is sourced; the repo owns sourcing its own nested files.
  for plugin in "$__priv"/*/*.plugin.zsh(N); do
    [ -f "$plugin" ] && source "$plugin"
  done
fi
