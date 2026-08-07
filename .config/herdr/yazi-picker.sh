#!/usr/bin/env bash

set -uo pipefail

CALLER_PANE=$HERDR_ACTIVE_PANE_ID
tmp=$(mktemp /tmp/yazi-chosen.XXXXXX)

yazi --chooser-file="$tmp"

# nvim は bracketed paste をモードに関係なくバッファ挿入として扱うため、`herdr pane
# run` (paste) ではなく send-keys で 1 文字ずつ打つ必要がある
send_literal() {
  local text=$1 keys=() i ch
  for ((i = 0; i < ${#text}; i++)); do
    ch=${text:i:1}
    [[ $ch == " " ]] && ch=space
    keys+=("$ch")
  done
  herdr pane send-keys "$CALLER_PANE" "${keys[@]}" enter
}

if [[ -s "$tmp" ]]; then
  # chooser-file は改行区切り。1 行ずつ実行させないため空白区切りに変換
  paths=$(tr '\n' ' ' <"$tmp")
  current_cmd=$(herdr pane process-info --pane "$CALLER_PANE" |
    jq -r '.result.process_info.foreground_processes[0].name')

  if [[ "$current_cmd" == "nvim" ]]; then
    herdr pane send-keys "$CALLER_PANE" esc
    send_literal ":args $paths"
  else
    herdr pane run "$CALLER_PANE" "nvim $paths"
  fi
fi

rm -f "$tmp"
