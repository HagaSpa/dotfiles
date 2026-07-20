#!/usr/bin/env bats
# link.sh: symlink creation, idempotency, backup behavior, and source integrity.
# Each test runs against a temporary HOME so the real machine is never touched.

setup() {
  cd "$BATS_TEST_DIRNAME/.."
  TEST_HOME=$(mktemp -d)
  export HOME="$TEST_HOME"
}

teardown() {
  rm -rf "$TEST_HOME"
}

@test "link.sh is executable and has valid syntax" {
  [ -x ./link.sh ]
  bash -n ./link.sh
}

@test "--list prints source:destination pairs for every entry" {
  run ./link.sh --list
  [ "$status" -eq 0 ]
  [ -n "$output" ]
  while IFS= read -r line; do
    [[ "$line" == *:* ]]
  done <<<"$output"
}

@test "every source file exists in the repo" {
  missing=()
  while IFS=':' read -r source _; do
    [ -e "$source" ] || missing+=("$source")
  done <<<"$(./link.sh --list)"
  [ "${#missing[@]}" -eq 0 ] || {
    echo "missing sources: ${missing[*]}"
    false
  }
}

@test "creates a symlink for every entry" {
  ./link.sh

  count=0
  while IFS=':' read -r _ target; do
    expanded_target=$(eval echo "$target")
    [ -L "$expanded_target" ] || {
      echo "not a symlink: $expanded_target"
      false
    }
    count=$((count + 1))
  done <<<"$(./link.sh --list)"

  expected=$(./link.sh --list | wc -l | tr -d ' ')
  [ "$count" -eq "$expected" ]
}

@test "second run is idempotent (skips every entry)" {
  ./link.sh
  run ./link.sh
  [ "$status" -eq 0 ]
  ! grep -q '^link:' <<<"$output"
  ! grep -q '^backup:' <<<"$output"
  grep -q '^skip:' <<<"$output"
}

@test "backs up an existing regular file before linking" {
  echo "pre-existing content" >"$HOME/.zshrc"

  ./link.sh

  [ -L "$HOME/.zshrc" ]
  [ -f "$HOME/.zshrc.bak" ]
  grep -q "pre-existing content" "$HOME/.zshrc.bak"
}
