#!/bin/bash
#
# Regenerate Brewfile.lock.json from the versions currently installed on
# this machine. Homebrew >= 6 dropped native `brew bundle` lockfile support,
# so this repo keeps its own minimal snapshot: {formulae: {name: version},
# casks: {token: version}} for every Brewfile entry.
#
# Run after `brew upgrade` or after editing the Brewfile, then commit the
# result. The weekly brew-outdated workflow compares this file against the
# latest versions on formulae.brew.sh.

set -euo pipefail

cd "$(dirname "$0")/../.."

formulae=$(grep -E '^brew "' Brewfile | sed 's/^brew "\([^"]*\)".*/\1/')
casks=$(grep -E '^cask "' Brewfile | sed 's/^cask "\([^"]*\)".*/\1/')

# shellcheck disable=SC2086 # word splitting over the entry lists is intended
brew info --json=v2 --formula $formulae >/tmp/brew-lock-formulae.json
# shellcheck disable=SC2086
brew info --json=v2 --cask $casks >/tmp/brew-lock-casks.json

jq -S -n \
  --slurpfile f /tmp/brew-lock-formulae.json \
  --slurpfile c /tmp/brew-lock-casks.json \
  '{
    formulae: ($f[0].formulae | map({(.name): (.installed[0].version // "not-installed")}) | add),
    casks: ($c[0].casks | map({(.token): (.installed // "not-installed")}) | add)
  }' >Brewfile.lock.json

rm -f /tmp/brew-lock-formulae.json /tmp/brew-lock-casks.json

echo "Brewfile.lock.json updated:"
jq . Brewfile.lock.json
