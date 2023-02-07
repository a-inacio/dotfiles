source ~/.config/zshrc/01-alias-core.sh
source ~/.config/zshrc/01-alias-development.sh
source ~/.config/zshrc/01-alias-tools.sh
source ~/.config/zshrc/02-bindings.sh

__extras_path="$HOME/.config/zshrc/extras"

if [ -d "$__extras_path" ]; then
  # Initialize the scripts array with a list of all .sh files in the folder
  scripts=( "$__extras_path"/*.sh )

  for script in "${scripts[@]}"; do
    if [ -f "$script" ]; then
      source "$script"
    fi
  done
else
  echo "> $__extras_path"
fi
