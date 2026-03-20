#!/usr/bin/env bash

CALLER_PANE=$1
tmp=$(mktemp /tmp/yazi-chosen.XXXXXX)

tmux new-session "yazi --chooser-file=$tmp" \; set status off

if [[ -s "$tmp" ]]; then
	paths=$(cat "$tmp")
	current_cmd=$(tmux display-message -t "$CALLER_PANE" -p '#{pane_current_command}')

	if [[ "$current_cmd" == "hx" ]]; then
		tmux send-keys -t "$CALLER_PANE" Escape
		tmux send-keys -t "$CALLER_PANE" ":open $paths"
		tmux send-keys -t "$CALLER_PANE" Enter
	else
		tmux send-keys -t "$CALLER_PANE" "hx \"$paths\""
		tmux send-keys -t "$CALLER_PANE" Enter
	fi
fi

rm -f "$tmp"
