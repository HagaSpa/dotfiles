## fzf
fzf-select-history() {
   BUFFER=$(history -n -r 1 | fzf --query "$LBUFFER")
   CURSOR=$#BUFFER
   zle reset-prompt
}
zle -N fzf-select-history
bindkey '^t' fzf-select-history

fzf-select-history-uniq() {
   local tac=${commands[tac]:-"tail -r"}
   BUFFER=$( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | sed 's/ *[0-9]* *//' | 
	eval $tac | awk '!a[$0]++' | fzf +s)
   CURSOR=$#BUFFER
   zle clear-screen
}
zle -N fzf-select-history-uniq
bindkey '^r' fzf-select-history-uniq
 
# copy a line Ctrl + CP
history-current-pbcopy() {
  print "$BUFFER" | tr -d "\r\n" | pbcopy
}
zle -N history-current-pbcopy
bindkey '^P^O' history-current-pbcopy

# Fix completion display issues in tmux
# Tab 1回 の候補選択開始時と、候補確定で入力文字列が重複する問題の修正。
# 2回目以降の Tab で候補を選択してる最中は重複してしまう。
# https://github.com/HagaSpa/dotfiles/issues/43
if [[ -n "$TMUX" ]]; then
  _fix_completion_display() {
    # Clear the line using terminal escape sequences
    printf '\r\033[2K'
    # Redraw the prompt
    zle reset-prompt
    # Perform completion
    zle expand-or-complete
    # After completion, ensure clean redisplay
    zle redisplay
  }
  zle -N fix-completion-display _fix_completion_display
  bindkey '^I' fix-completion-display
fi


# ==========================
# Generic workspace navigation function
# ==========================
_workspace_navigate() {
  local org_name="$1"
  local workspace_path="$2"
  local target="$3"
  
  # Set default path
  local REPO="$workspace_path"

  # If inside a Git repo and it's the target organization, override REPO
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local remote_url dir_name current_org
    remote_url=$(git remote get-url origin 2>/dev/null)
    dir_name=$(dirname "$remote_url")
    current_org=$(basename "$dir_name")

    if [[ "$current_org" == "$org_name" ]]; then
      REPO="$(git rev-parse --show-toplevel)"
    fi
  fi

  if [[ -z "$target" ]]; then
    cd "$REPO"
  else
    # Try exact match first
    if [[ -d "$REPO/$target" ]]; then
      cd "$REPO/$target"
    else
      # Try prefix match
      local matches=()
      for dir in "$REPO"/*; do
        if [[ -d "$dir" && "$(basename "$dir")" == "$target"* ]]; then
          matches+=("$dir")
        fi
      done

      if [[ ${#matches[@]} -eq 1 ]]; then
        local matched_dir="${matches[1]}"
        echo "[workspace] Moving to: $(basename "$matched_dir")"
        cd "$matched_dir"
      elif [[ ${#matches[@]} -gt 1 ]]; then
        echo "Multiple matches found for '$target':"
        for match in "${matches[@]}"; do
          echo "  - $(basename "$match")"
        done
        return 1
      else
        echo "No directory found matching '$target'"
        return 1
      fi
    fi
  fi
}

# ==========================
# Generic workspace completion function
# ==========================
_workspace_complete() {
  local org_name="$1"
  local workspace_path="$2"
  local prefix="${words[CURRENT]}"

  # Set default path
  local REPO="$workspace_path"

  # If inside a Git repo and it's the target organization, override REPO
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local remote_url dir_name current_org
    remote_url=$(git remote get-url origin 2>/dev/null)
    dir_name=$(dirname "$remote_url")
    current_org=$(basename "$dir_name")

    if [[ "$current_org" == "$org_name" ]]; then
      REPO="$(git rev-parse --show-toplevel)"
    fi
  fi

  # Add directories that match the prefix
  local dirs=()
  for p in "$REPO/"*/; do
    if [[ -d "$p" ]]; then
      local dirname="$(basename "$p")"
      # Add if it matches the prefix or if no prefix given
      if [[ -z "$prefix" || "$dirname" == "$prefix"* ]]; then
        dirs+=("$dirname")
      fi
    fi
  done

  compadd -Q -- "${dirs[@]}"
}

# ==========================
# hagaspa function
# ==========================
hagaspa() {
  _workspace_navigate "HagaSpa" "$HOME/workspaces/hagaspa" "$1"
}

_hagaspa() {
  _workspace_complete "HagaSpa" "$HOME/workspaces/hagaspa"
}

compdef _hagaspa hagaspa

# ==========================
# OLTAInc function
# ==========================
OLTAInc() {
  _workspace_navigate "OLTAInc" "$HOME/workspaces/OLTAInc" "$1"
}

_OLTAInc() {
  _workspace_complete "OLTAInc" "$HOME/workspaces/OLTAInc"
}

compdef _OLTAInc OLTAInc

# Alias for OLTAInc
olta() {
  _workspace_navigate "OLTAInc" "$HOME/workspaces/OLTAInc" "$1"
}

_olta() {
  _workspace_complete "OLTAInc" "$HOME/workspaces/OLTAInc"
}

compdef _olta olta




# ==========================
# gw function
# ==========================
gw() {
  # Define Git repository root
  local WT_ROOT="$HOME/worktrees"
  local wt_name="$1"

  # Get current Git repository root
  local repo_root
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    echo "Not inside a Git repository"
    return 1
  }

  # Parse GitHub remote URL to get owner and repo name
  local remote_url
  remote_url=$(git config --get remote.origin.url)
  if [[ "$remote_url" =~ github.com[:/](.*)/(.*)(\.git)?$ ]]; then
    local owner="${match[1]}"
    local repo="${match[2]%.git}"
  else
    echo "Unsupported or missing remote URL: $remote_url"
    return 1
  fi

  # If no argument: go to main repository (even from a worktree)
  if [[ -z "$wt_name" ]]; then
    if [[ -f "$repo_root/.git" ]]; then
      local gitdir_line
      gitdir_line=$(<"$repo_root/.git")
      if [[ "$gitdir_line" =~ gitdir:\ (.*)/\.git/worktrees/.* ]]; then
        local main_repo_path="${match[1]}"
        echo "[gw] Moving to main repository: $main_repo_path"
        cd "$main_repo_path" || return 1
        return 0
      fi
    fi

    echo "[gw] Already in main repository: $repo_root"
    cd "$repo_root" || return 1
    return 0
  fi

  local base_dir="$WT_ROOT/$owner/$repo"
  local target_dir="$base_dir/$wt_name"

  if [[ -d "$target_dir" ]]; then
    echo "[gw] Switching to existing worktree: $target_dir"
    cd "$target_dir" || return 1
    return 0
  fi

  echo "[gw] Worktree does not exist: $target_dir"
  echo -n "Create new worktree from origin/<default-branch>? [Enter = Yes, Ctrl+C = Cancel] "
  read

  # Only here: determine default branch from remote
  local default_branch
  default_branch=$(git remote show origin 2>/dev/null | awk '/HEAD branch/ {print $NF}')
  default_branch=${default_branch:-main}

  echo "[gw] Creating new worktree '$wt_name' from origin/$default_branch"
  mkdir -p "$base_dir"
  git fetch origin "$default_branch"
  git worktree add "$target_dir" "origin/$default_branch" || return 1
  cd "$target_dir" || return 1
}

# ==========================
# gw completion (_gw)
# ==========================
_gw() {
  local WT_ROOT="$HOME/worktrees"

  local remote_url=$(git config --get remote.origin.url 2>/dev/null)
  [[ "$remote_url" =~ github.com[:/](.*)/(.*)(\.git)?$ ]] || return
  local owner="${match[1]}"
  local repo="${match[2]%.git}"

  local base_dir="$WT_ROOT/$owner/$repo"
  [[ -d "$base_dir" ]] || return

  local -a worktrees
  worktrees=(${(f)"$(find "$base_dir" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null)"})

  compadd -Q -- "${worktrees[@]}"
}
compdef _gw gw
