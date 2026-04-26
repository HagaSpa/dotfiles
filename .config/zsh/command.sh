# copy a line Ctrl + CP
history-current-pbcopy() {
  print "$BUFFER" | tr -d "\r\n" | pbcopy
}
zle -N history-current-pbcopy
bindkey '^P^O' history-current-pbcopy

# clear screen Ctrl + G (Ctrl+L is remapped to right_arrow by Karabiner)
bindkey '^G' clear-screen

# Switch to the remote default branch and pull. Falls back to `main` if
# refs/remotes/origin/HEAD is not set (e.g. repos created via `git init`
# + `git remote add` rather than `git clone`).
gbm() {
  local branch
  branch=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's@^origin/@@')
  : "${branch:=main}"
  git switch "$branch" && git pull
}
