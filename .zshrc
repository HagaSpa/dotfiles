# eval
eval "$(zoxide init zsh)"
# eval "$(nodenv init -)"
eval "$(starship init zsh)"
eval "$(sheldon source)"

# alias
alias ls='lsd'
alias l='lsd -l -a'
alias z-='z -'

## fzf
function fzf-select-history() {
    BUFFER=$(history -n -r 1 | fzf --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle reset-prompt
}
zle -N fzf-select-history
bindkey '^t' fzf-select-history

function fzf-select-history-uniq() {
    local tac=${commands[tac]:-"tail -r"}
    BUFFER=$( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | sed 's/ *[0-9]* *//' | eval $tac | awk '!a[$0]++' | fzf +s)
    CURSOR=$#BUFFER
    zle clear-screen
}
zle -N  fzf-select-history-uniq
bindkey '^r' fzf-select-history-uniq

# copy a line Ctrl + P O
function history-current-pbcopy() {
  print "$BUFFER" | tr -d "\r\n" | pbcopy
}
zle -N history-current-pbcopy
bindkey '^P^O' history-current-pbcopy
