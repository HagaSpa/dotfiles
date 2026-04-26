
alias ls='lsd'
alias l='lsd -l -a'

alias z-='z -'
alias z..='z ..'
alias haga="z ~/workspaces/hagaspa"
alias olta="z ~/workspaces/OLTAInc"

# git aliases
alias ga='git add'
alias ga.='git add .'
alias gb='git switch'
alias gb-='git switch -'
alias gbc='git switch -c'
alias gd='git add -N . && git diff'
alias gs='git status --short --branch'
alias gl='git log --graph --decorate --oneline'
alias gc='git commit -m'
alias gcm='git commit'
alias gca='git commit --amend --no-edit'
alias gp='git push'
alias gpu='git push -u origin $(git branch --show-current)'
alias gpl='git pull'
alias gnah='git nah'
alias grs='git reset --soft'
alias vg='gh pr view --web'
