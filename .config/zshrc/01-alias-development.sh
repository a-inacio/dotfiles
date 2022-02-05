alias k=kubectl
alias kx=kubectx
alias kns=kubens
alias pl=pulumi
alias plo="pulumi stack output -j | jq"

alias dc="docker compose"

# ------------------------------------------------------------------------------
# Git
# ------------------------------------------------------------------------------
alias gs="git status"
alias ga="git add . && git status"
alias gp="git pull --rebase"
alias gc="git commit"
alias gP="git pull --rebase && git push"
alias gd="git diff"
alias gChor="git remote set-url origin"
alias gAor="git remote add origin"
alias gSu="git submodule update --remote --merge"
alias gSi="git submodule update --init --recursive"

# Undo add
alias gUa="git restore --stage . && git status"

# Undo commit, keep changes: https://stackoverflow.com/questions/15772134/can-i-delete-a-git-commit-but-keep-the-changes
alias gUc="git reset HEAD^ && git status"

# Push current branch to origin
alias gPorr="git branch --show-current | xargs -I {} git -c 'push --set-upstream origin {}'"

# ------------------------------------------------------------------------------
# Yadm
# ------------------------------------------------------------------------------
alias ys="yadm status"
alias ya="yadm add -u && yadm status"
alias yp="yadm pull"
alias yc="yadm commit"
alias yP="yadm pull && yadm push"
alias yd="yadm diff"
alias ySu="yadm submodule update --remote --merge"
alias ySi="yadm submodule update --init --recursive"

# Undo add
alias yUa="yadm restore --stage . && yadm status"

# Undo commit
alias yUc="yadm reset HEAD^ && yadm status"
