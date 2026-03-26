# copy a line Ctrl + CP
history-current-pbcopy() {
  print "$BUFFER" | tr -d "\r\n" | pbcopy
}
zle -N history-current-pbcopy
bindkey '^P^O' history-current-pbcopy

# clear screen Ctrl + G (Ctrl+L is remapped to right_arrow by Karabiner)
bindkey '^G' clear-screen

# fuzzy find with bat preview
fp() { fzf --preview 'bat --color=always {}'; }

# Ctrl+]: search files from ~/workspaces
fzf-workspaces-widget() {
  setopt localoptions pipefail no_aliases 2> /dev/null
  local item selected
  selected=$(
    fd --type f --hidden --follow --no-require-git --exclude .git --exclude .DS_Store . ~/workspaces |
    fzf --reverse --scheme=path -m < /dev/tty | while read -r item; do
      echo -n -E "${(q)item} "
    done
    echo
  )
  LBUFFER="${LBUFFER}${selected}"
  zle reset-prompt
}
zle -N fzf-workspaces-widget
bindkey '^\]' fzf-workspaces-widget

