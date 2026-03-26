# copy a line Ctrl + CP
history-current-pbcopy() {
  print "$BUFFER" | tr -d "\r\n" | pbcopy
}
zle -N history-current-pbcopy
bindkey '^P^O' history-current-pbcopy

# clear screen Ctrl + G (Ctrl+L is remapped to right_arrow by Karabiner)
bindkey '^G' clear-screen


