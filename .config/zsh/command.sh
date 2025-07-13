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


# ==========================
# hagaspa completion (hagaspa)
# ==========================
hagaspa() {
  # Set default path
  REPO="$HOME/workspaces/hagaspa"

  # If inside a Git repo and it's dinii-self-all, override REPO
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local remote_url dir_name org_name
    remote_url=$(git remote get-url origin 2>/dev/null)
    dir_name=$(dirname "$remote_url")
    org_name=$(basename "dir_name")

    if [[ "$org_name" == "HagaSpa" ]]; then
      REPO="$(git rev-parse --show-toplevel)"
    fi
  fi

  case $1 in
  "all"|"root"|"") cd "$REPO" ;;
  *) cd "$REPO/$1" ;;
  esac
}

# ==========================
# hagaspa completion (_hagaspa)
# ==========================
_hagaspa() {
  # Set default path
  local REPO="$HOME/workspaces/hagaspa"

  # If inside a Git repo and it's dinii-self-all, override REPO
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local remote_url dir_name org_name
    remote_url=$(git remote get-url origin 2>/dev/null)
    dir_name=$(dirname "$remote_url")
    org_name=$(basename "dir_name")

    if [[ "$org_name" == "HagaSpa" ]]; then
      REPO="$(git rev-parse --show-toplevel)"
    fi
  fi

  # Add only actual directories under packages/ as candidates
  local dirs=()
  for p in "$REPO/"*/; do
    [[ -d "$p" ]] && dirs+=("$(basename "$p")")
  done

  compadd "$dirs[@]"
}

compdef _hagaspa hagaspa


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


