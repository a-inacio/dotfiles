alias sz="source ~/.config/zshrc/00-all.sh"
alias ez="vim ~/.config/zshrc/00-all.sh"

alias szz="source ~/.zshrc"
alias ezz="vim ~/.zshrc"

alias ll="ls -l"
alias la="ls -a"

alias lt="tree -L 2"
alias ltt="tree -L 3"

alias ff="grep -rnw . -e"

alias pbpwd="pwd|pbcopy"
alias pbcd="cd \"`pbpaste`\""

alias ..="cd .."

alias grlias="alias | grep"

alias t="tmux"
alias tls="tmux ls"
alias tsz="tmux source ~/.tmux.conf"
alias tez="vim ~/.tmux.conf"

function tk(){
  tmux list-sessions | grep -v attached | awk 'BEGIN{FS=":"}{print $1}' | xargs -n 1 tmux kill-session -t
}
