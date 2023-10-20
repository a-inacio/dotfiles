# ------------------------------------------------------------------------------
# DevOps
# ------------------------------------------------------------------------------
alias k=kubectl
alias kx=kubectx
alias kns=kubens

ksh() {
  kubectl exec --stdin --tty $1 -- /bin/bash
}

alias dc="docker-compose"
# https://phoenixnap.com/kb/docker-run-override-entrypoint
alias drsh="docker run -it --entrypoint /bin/bash"

# https://phoenixnap.com/kb/how-to-ssh-into-docker-container
alias dsh="_dsh"
_dsh() {
    docker exec -it $1 /bin/bash
}

alias plias="alias | grep \"^pl"\"

alias pl=pulumi
alias plo="pulumi stack output -j | jq"
alias pl=pulumi
alias plup="pulumi up"
alias plupy="pulumi up -y"
alias plo="pulumi stack output -j | jq"
alias plos="pulumi stack output --show-secrets -j | jq"
alias plsl="pulumi stack select"
alias plugrade="brew upgrade pulumi"
alias plcs="pulumi config --show-secrets"
alias plcsj="pulumi config --show-secrets -j | jq"
alias plkonf="plkconfget"
alias plcset="pulumi config set"
alias plcget="pulumi config get"
alias plcget64="plconfget64"
alias plfix="rm -rf node_modules && yarn"

alias plchk="_plchk"

_plchk() {
    git pull --rebase && pulumi preview | awk '/./{line=$0} END{print line}'
}

plkconfget() {
  pulumi stack output kubeconfig --show-secrets > .plkconf.kubeconfig
  KUBECONFIG=.plkconf.kubeconfig:~/.kube/config kubectl config view --flatten > .plkconf.merged.kubeconfig
  mv .plkconf.merged.kubeconfig ~/.kube/config
  rm -rf .plkconf.kubeconfig
  chmod go-r ~/.kube/config 
}

plconfget64() {
  pulumi config get  --path ${1} | jq .'"'${2}'"' -r | base64 -d
}

export PULUMI_K8S_SUPPRESS_DEPRECATION_WARNINGS=true

# ------------------------------------------------------------------------------
# SSH / networking
# ------------------------------------------------------------------------------
alias lsh="grep -e \"^Host\" ~/.ssh/config | awk '{print \$2}'"
alias esh="vim ~/.ssh/config"

alias ips='ifconfig | awk '"'"'/inet / {print $2}'"'"
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

alias ipscan='_ipscan(){ nmap -sn $1.0/24 | grep report | sed s/Nmap\ scan\ report\ for\ //g }; _ipscan'
alias scanport='_scanport(){ lsof -nP -i:"$1" | grep LISTEN }; _scanport'
alias killport='_scanportpid(){ kill -9 `lsof -nP -i:"$1" | grep LISTEN | awk '"'"'{print $2}'"'"'` }; _scanportpid'

# ------------------------------------------------------------------------------
# Git
# ------------------------------------------------------------------------------
# Too much bloat, but a good inspiration
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git
alias glias='alias | grep "='\''git"'

alias g="git"
alias gs="git status"
alias ga="git add"
alias gaa="git add . && git status"
alias gp="git pull --rebase"
alias gc="git commit"
alias gP="git pull --rebase && git push"
alias gPt="git pull --rebase && git push --tags"
alias gd="git diff"
alias gds="git diff --staged"
alias gChor="git remote set-url origin"
alias gAor="git remote add origin"
alias gSu="git submodule update --remote --merge"
alias gSi="git submodule update --init --recursive"
alias gR="git restore"
alias gRH="git reset --hard"
alias gco="git checkout"
alias gba="git branch --all"
alias gpp="git pull --rebase --recurse-submodules"

alias gClean="_gClean"
_gClean(){
  git status --porcelain .| awk '{if ($1 == "??") print $2}' | xargs -I {} rm -rf {}
}

alias gNuke="git reset --hard && git clean -fdx"

alias gI="_gI"
_gI(){
  git init --initial-branch=$1
}

alias gPor="_gPor"
_gPor(){
  git push -u origin $1
}

# Undo add
alias gUa="git restore --stage . && git status"

# Forgot what this does 🙈... tried it and it removed everything
# Next time best to explain...
#alias gUUa="git rm -r --cached ."

# Undo commit, keep changes
# https://stackoverflow.com/questions/15772134/can-i-delete-a-git-commit-but-keep-the-changes
alias gUc="git reset HEAD^ && git status"

# Push current branch to origin
alias gPPor="git branch --show-current | xargs -I {} bash -c 'git push --set-upstream origin {}'"

# Open the repo page in the browser
alias ggo="_ggo"

# Project url (TODO only working for gitlab for now!)
alias ggurl="_ggurl"

# Project path
alias ggpath="_ggpath"

# Project name
alias ggname="_ggname"

_ggname(){
  basename `_ggpath`
}

_ggo(){
  echo "https://"`_ggurl` | xargs open;
}

_ggpath(){
  echo `cut -d '.' -f1 <<< $(cut -d ':' -f2 <<< $(git ls-remote --get-url))`
}

_ggurl(){
  echo "gitlab.com/"`_ggpath`
}

# ------------------------------------------------------------------------------
# Yadm
# ------------------------------------------------------------------------------
alias ylias='alias | grep "='\''yadm"'
alias yboot="yadm bootstrap"
alias yeboot="vim ~/.config/yadm/bootstrap"
alias yebrew="vim ~/.Brewfile"
alias ys="yadm status"
alias ya="yadm add"
alias yaa="yadm add -u && yadm status"
alias yp="yadm pull --rebase"
alias ypp="yadm pull --rebase --recurse-submodules"
alias yc="yadm commit"
alias yP="yadm pull --rebase && yadm push"
alias yd="yadm diff"
alias yds="yadm diff --staged"
alias ySu="yadm submodule update --remote --merge"
alias ySi="yadm submodule update --init --recursive"
alias ySa="yadm submodule add"

# Undo add
alias yUa="yadm restore --stage . && yadm status"

# Undo commit
alias yUc="yadm reset HEAD^ && yadm status"

# ------------------------------------------------------------------------------
# Productivity
# ------------------------------------------------------------------------------
_gworkon(){
  [ -z "$1" ] && cat ~/.gworkon | tr -d '\r\n' | pbcopy || echo $1 > ~/.gworkon
}

# Keep the current task for an easier reference later
alias wo="_gworkon"
alias wogo="cat ~/.gworkon | tr -d '\r\n' | xargs open"

# Convential commits with the current task link added to the clipboard
alias cz="_gworkon && git-cz --disable-emoji"

pbclone() {
  echo "Cloning \""`pbpaste`"\"... 🤞"
  git clone `pbpaste` $1
}

# ------------------------------------------------------------------------------
# Utils
# ------------------------------------------------------------------------------

alias uui="uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '\n' | pbcopy"
