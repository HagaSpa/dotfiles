# EDITOR=nvim だと zsh が vi モードを推測するため、emacs キーバインドを明示する。
# 個別の bindkey を上書きしないよう、必ずファイル先頭に置くこと。
bindkey -e

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

# Home Row Mods cheatsheet. tmux からは prefix + m の popup でも開ける。
hrm() {
  bat --style=plain --color=always --paging=always ~/.config/karabiner/HRM.md
}
