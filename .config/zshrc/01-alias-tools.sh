alias fkopen="open -a ForkLift ."
alias gvim="Emacs"

# maybe not needed
# alias brew86="arch -x86_64 /usr/local/homebrew/bin/brew"

# Fixes issues with brew on M1
if  [ -f "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
