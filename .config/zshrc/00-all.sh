source ~/.config/zshrc/01-alias-core.sh
source ~/.config/zshrc/01-alias-development.sh
source ~/.config/zshrc/01-alias-tools.sh
source ~/.config/zshrc/02-bindings.sh

__extras_path="$HOME/.config/zshrc/extras"

if [ -d "$__extras_path" ]; then
  # Sorted list of .sh files (numeric NN- prefix controls load order);
  # (N) = nullglob, so an empty dir yields no entries instead of a literal glob.
  scripts=( "$__extras_path"/*.sh(N) )

  for script in "${scripts[@]}"; do
    if [ -f "$script" ]; then
      source "$script"
    fi
  done
fi
