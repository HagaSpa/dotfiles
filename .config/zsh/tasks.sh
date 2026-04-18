#!/bin/zsh
# Obsidian vault 内の Markdown タスクを扱う簡易 CLI
# 記法は Obsidian Tasks plugin 互換
#   - [ ] 内容 📅 YYYY-MM-DD ⏫/🔼/🔽 🔗 url #project/x #okr/y

_tasks_vault="$HOME/workspaces/hagaspa/obsidian"
_tasks_inbox="$_tasks_vault/tasks/inbox.md"
_tasks_active="$_tasks_vault/tasks/active.md"

# tc: task capture - inbox.md に追記
tc() {
  emulate -L zsh
  local due="" priority="" slack_url=""
  local -a tags

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -d|--due)      due="$2"; shift 2 ;;
      -p|--priority) priority="$2"; shift 2 ;;
      -t|--tag)      tags+=("#$2"); shift 2 ;;
      -s|--slack)    slack_url="$2"; shift 2 ;;
      -h|--help)
        cat <<'EOF'
Usage: tc [options] "task content"
  -d, --due YYYY-MM-DD    期限
  -p, --priority h|m|l    優先度 (high/mid/low)
  -t, --tag <slug>        タグ (複数可、# は自動付与)
  -s, --slack <url>       Slack permalink
EOF
        return 0 ;;
      --) shift; break ;;
      -*) echo "tc: 不明なオプション $1" >&2; return 1 ;;
      *) break ;;
    esac
  done

  if (( $# == 0 )); then
    echo "tc: タスク内容が必要です (tc -h でヘルプ)" >&2
    return 1
  fi

  if [[ ! -f "$_tasks_inbox" ]]; then
    echo "tc: $_tasks_inbox が存在しません" >&2
    return 1
  fi

  local line="- [ ] $*"
  [[ -n "$due" ]] && line+=" 📅 $due"
  case "$priority" in
    h|high)       line+=" ⏫" ;;
    m|mid|medium) line+=" 🔼" ;;
    l|low)        line+=" 🔽" ;;
  esac
  [[ -n "$slack_url" ]] && line+=" 🔗 $slack_url"
  if (( ${#tags[@]} > 0 )); then
    line+=" ${tags[*]}"
  fi

  print -r -- "$line" >> "$_tasks_inbox"
  echo "→ $_tasks_inbox"
  echo "  $line"
}

# _tasks_list_open: 未完了タスクを `file:line:content` 形式で列挙
#   HTML コメント `<!-- ... -->` 内の `- [ ]` は除外（記法サンプル行などを拾わない）
_tasks_list_open() {
  emulate -L zsh
  local f
  for f in "$_tasks_vault/tasks"/*.md(.N); do
    awk -v f="$f" '
      /<!--/ { in_c = 1 }
      !in_c && /^- \[ \]/ { print f ":" NR ":" $0 }
      /-->/ { in_c = 0 }
    ' "$f"
  done
}

# tt: task agenda - fzf で未完了タスク閲覧、Enter で Helix 起動
# NOTE: zsh では `path` が `PATH` と tied な特殊変数なのでローカルでも使わない
tt() {
  emulate -L zsh
  if [[ ! -d "$_tasks_vault/tasks" ]]; then
    echo "tt: $_tasks_vault/tasks/ が見つかりません" >&2
    return 1
  fi

  local selected
  selected=$(_tasks_list_open \
    | fzf --delimiter=':' \
          --with-nth=3.. \
          --preview "bat --color=always --style=numbers --highlight-line {2} {1}" \
          --preview-window=down:50%:wrap \
          --prompt='task> ') || return 0

  [[ -z "$selected" ]] && return 0

  local file="${selected%%:*}"
  local rest="${selected#*:}"
  local line_num="${rest%%:*}"

  ${EDITOR:-hx} "$file:$line_num"
}

# td: task done - fzf で選択して `- [x] ... ✅ today` に変換
td() {
  emulate -L zsh
  local today
  today=$(date +%F)

  local selected
  selected=$(_tasks_list_open \
    | fzf --delimiter=':' \
          --with-nth=3.. \
          --preview "bat --color=always --style=numbers --highlight-line {2} {1}" \
          --preview-window=down:50%:wrap \
          --prompt='done> ') || return 0

  [[ -z "$selected" ]] && return 0

  local file="${selected%%:*}"
  local rest="${selected#*:}"
  local line_num="${rest%%:*}"

  local tmp
  tmp=$(mktemp)
  awk -v ln="$line_num" -v d="$today" '
    NR == ln {
      sub(/^- \[ \]/, "- [x]")
      if ($0 !~ /✅ [0-9]{4}-[0-9]{2}-[0-9]{2}/) {
        $0 = $0 " ✅ " d
      }
    }
    { print }
  ' "$file" > "$tmp" && mv "$tmp" "$file"

  echo "→ 完了: $file:$line_num"
  sed -n "${line_num}p" "$file"
}
