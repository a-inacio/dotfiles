# PATH + core environment. Sourced by ~/.zshrc BEFORE oh-my-zsh, so tools are on
# PATH and the framework/theme see the right environment.

# Keep PATH entries unique so re-sourcing this file doesn't stack duplicates.
typeset -U path PATH

export GOPATH=$HOME/go

export PATH="$HOME/.local/bin:$PATH"
# ~/bin: default bin for tfswitch (terraform) and similar version managers that
# fall back here when /usr/local/bin isn't writable. Kept on PATH so whatever
# they drop here is picked up. .profile adds this for bash; zsh needs it here.
export PATH="$HOME/bin:$PATH"
export PATH=$HOME/.sbin:${PATH}
export PATH=$GOPATH/bin:${PATH}
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

export VISUAL=nvim
export EDITOR=nvim

# Use english (https://unix.stackexchange.com/questions/87745/what-does-lc-all-c-do)
export LC_ALL=en_US.UTF-8

# SpaceVim - python support for neovim
export PYTHON3_HOST_PROG=$(command -v python3)
export PYTHON_HOST_PROG=$(command -v python)

export VIM_DOTFILES_DIR="$HOME/.config/vim"
