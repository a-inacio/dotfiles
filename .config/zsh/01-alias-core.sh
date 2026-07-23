alias sz="source ~/.config/zshrc/00-all.sh"
alias ez="vim ~/.config/zshrc/00-all.sh"

alias szz="source ~/.zshrc"
alias ezz="vim ~/.zshrc"

alias ll="ls -l"
alias la="ls -a"

alias lt="tree -L 2"
alias ltt="tree -L 3"

alias ff="grep -rnw . -e"

alias pbf=_pbf
_pbf(){
  osascript \
    -e 'on run args' \
    -e 'set the clipboard to POSIX file args'\
    -e end \
    "$(greadlink -f -- $1)"
}

_pbf_completion() {
     _files
}
compdef _pbf_completion pbf

alias bhist="history | vim \"+normal G$\" -"

alias pbpwd="pwd|pbcopy"
alias pbcd='cd "$(pbpaste)"'

alias ..="cd .."

alias grlias="alias | grep"

alias me="curl -4 ifconfig.me"

alias fdns="sudo dscacheutil -flushcache;sudo killall -HUP mDNSResponder"

# if we have `z`, then it becomes our `cd`
#if command -v z >/dev/null 2>&1; then alias cd='z'; fi

#inspiration for more https://tmuxcheatsheet.com/
alias t="tmux"
alias ta="tmux a"
alias tls="tmux ls"
alias tsz="tmux source ~/.tmux.conf"
alias tez="vim ~/.tmux.conf"

function tk(){
  tmux list-sessions | grep -v attached | awk 'BEGIN{FS=":"}{print $1}' | xargs -n 1 tmux kill-session -t
}

unalias vim > /dev/null 2>&1
alias vi=`which vim`
alias vim=`which nvim`
alias v=vim
