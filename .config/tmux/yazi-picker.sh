#!/usr/bin/env bash

CALLER_PANE=$1
tmp=$(mktemp /tmp/yazi-chosen.XXXXXX)

tmux new-session "yazi --chooser-file=$tmp" \; set status off

if [[ -s "$tmp" ]]; then
  # chooser-file は改行区切り。send-keys に改行を渡すと途中で実行されるため空白区切りに変換
  paths=$(tr '\n' ' ' <"$tmp")
  current_cmd=$(tmux display-message -t "$CALLER_PANE" -p '#{pane_current_command}')

  if [[ "$current_cmd" == "nvim" ]]; then
    tmux send-keys -t "$CALLER_PANE" Escape
    tmux send-keys -t "$CALLER_PANE" ":args $paths"
    tmux send-keys -t "$CALLER_PANE" Enter
  else
    tmux send-keys -t "$CALLER_PANE" "nvim $paths"
    tmux send-keys -t "$CALLER_PANE" Enter
  fi
fi

rm -f "$tmp"
