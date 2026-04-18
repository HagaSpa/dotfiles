#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source path only: destination is ~/{source}
# source:destination: destination differs from ~/{source}
entries=(
  .config/fd/config
  .config/ghostty/config
  .config/helix/config.toml
  .config/helix/languages.toml
  .config/helix/themes/bogster-custom.toml
  .config/helix/yazi-picker.sh
  .config/karabiner/assets/complex_modifications/personal_hagaspa.json
  .config/sheldon/plugins.toml
  .config/yazi/init.lua
  .config/yazi/keymap.toml
  .config/yazi/package.toml
  .config/yazi/yazi.toml
  .config/zsh/alias.sh
  .config/zsh/command.sh
  .config/zsh/hosts/work.sh
  .config/zsh/tasks.sh
  .gitconfig
  .gitconfig-olta
  .mise.toml
  .vimrc
  .zshenv
  .zshrc
  ".config/cursor/settings.json:~/Library/Application Support/Cursor/User/settings.json"
  ".config/cursor/keybindings.json:~/Library/Application Support/Cursor/User/keybindings.json"
  ".config/starship/starship.toml:~/.config/starship.toml"
  ".config/tmux/tmux.conf:~/.tmux.conf"
)

to_pair() {
  if [[ "$1" == *:* ]]; then
    echo "$1"
  else
    echo "$1:~/$1"
  fi
}

link() {
  local src="$SCRIPT_DIR/$1"
  local dst
  dst=$(eval echo "$2")

  mkdir -p "$(dirname "$dst")"

  if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$src" ]]; then
    echo "skip: $dst"
    return
  fi

  if [[ -e "$dst" || -L "$dst" ]]; then
    mv "$dst" "${dst}.bak"
    echo "backup: $dst"
  fi

  ln -s "$src" "$dst"
  echo "link: $dst -> $src"
}

if [[ "${1:-}" == "--list" ]]; then
  for entry in "${entries[@]}"; do
    to_pair "$entry"
  done
  exit 0
fi

for entry in "${entries[@]}"; do
  IFS=":" read -r src dst <<< "$(to_pair "$entry")"
  link "$src" "$dst"
done
