#!/usr/bin/env bats
# Configuration files: existence and syntax validation.

setup() {
  cd "$BATS_TEST_DIRNAME/.."
}

@test "shell configurations exist" {
  [ -f .zshrc ]
  [ -f .config/zsh/alias.sh ]
  [ -f .config/zsh/command.sh ]
}

@test "vim configuration exists" {
  [ -f .vimrc ]
}

@test "karabiner source and generated profile exist" {
  [ -f .config/karabiner/karabiner.ts ]
  [ -f .config/karabiner/karabiner.json ]
}

@test "ghostty configuration exists" {
  [ -f .config/ghostty/config ]
}

@test "sheldon plugins.toml exists" {
  [ -f .config/sheldon/plugins.toml ]
}

@test "tmux configuration exists" {
  [ -f .config/tmux/tmux.conf ]
}

@test "tmux configuration syntax is valid" {
  command -v tmux >/dev/null 2>&1 || skip "tmux not available"
  tmux -f .config/tmux/tmux.conf list-keys >/dev/null 2>&1
}

@test "karabiner.json is valid JSON" {
  python3 -m json.tool .config/karabiner/karabiner.json >/dev/null
}
