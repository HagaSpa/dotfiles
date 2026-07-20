#!/usr/bin/env bats
# Brewfile: structure and required entries.
# `brew bundle check` is informational only — CI does not pre-install
# every package, so unmet dependencies are expected and never fail.

setup() {
  cd "$BATS_TEST_DIRNAME/.."
}

@test "Brewfile exists and contains brew/cask entries" {
  [ -f ./Brewfile ]
  grep -Eq '^(brew|cask|mas)' ./Brewfile
}

@test "essential CLI tools are declared" {
  missing=()
  for tool in fzf gh zoxide tmux; do
    grep -q "brew \"$tool\"" ./Brewfile || missing+=("$tool")
  done
  [ "${#missing[@]}" -eq 0 ] || {
    echo "missing brew entries: ${missing[*]}"
    false
  }
}

@test "cask applications are declared" {
  missing=()
  for app in ghostty zed; do
    grep -q "cask \"$app\"" ./Brewfile || missing+=("$app")
  done
  [ "${#missing[@]}" -eq 0 ] || {
    echo "missing cask entries: ${missing[*]}"
    false
  }
}

@test "Brewfile.lock.json exists and is valid JSON" {
  [ -f ./Brewfile.lock.json ]
  python3 -m json.tool ./Brewfile.lock.json >/dev/null
}

@test "lockfile covers every Brewfile entry (regenerate with update-brew-lock.sh)" {
  command -v jq >/dev/null 2>&1 || skip "jq not available"

  diff \
    <(grep -E '^brew "' Brewfile | sed 's/^brew "\([^"]*\)".*/\1/' | sort) \
    <(jq -r '.formulae | keys[]' Brewfile.lock.json | sort)

  diff \
    <(grep -E '^cask "' Brewfile | sed 's/^cask "\([^"]*\)".*/\1/' | sort) \
    <(jq -r '.casks | keys[]' Brewfile.lock.json | sort)
}

@test "brew bundle check (informational, never fails)" {
  command -v brew >/dev/null 2>&1 || skip "brew not available"
  run brew bundle check --file=./Brewfile
  echo "$output"
  true
}
