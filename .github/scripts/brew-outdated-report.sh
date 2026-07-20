#!/bin/bash
#
# Compare Brewfile.lock.json against the latest versions published on
# formulae.brew.sh and print a markdown table of outdated entries to stdout.
# Needs only curl + jq (no Homebrew), so it runs anywhere. Prints nothing
# when everything is up to date. Always exits 0; the caller decides what to
# do with a non-empty report.

set -euo pipefail

cd "$(dirname "$0")/../.."

lock=Brewfile.lock.json
rows=""

latest_formula() {
  curl -fsSL "https://formulae.brew.sh/api/formula/$1.json" |
    jq -r '.versions.stable + (if .revision > 0 then "_\(.revision)" else "" end)'
}

latest_cask() {
  curl -fsSL "https://formulae.brew.sh/api/cask/$1.json" | jq -r '.version'
}

while read -r name locked; do
  latest=$(latest_formula "$name" || echo "unknown")
  if [ "$latest" != "$locked" ]; then
    rows="${rows}| $name | $locked | $latest |"$'\n'
  fi
done <<<"$(jq -r '.formulae | to_entries[] | "\(.key) \(.value)"' "$lock")"

while read -r token locked; do
  latest=$(latest_cask "$token" || echo "unknown")
  if [ "$latest" != "$locked" ]; then
    rows="${rows}| $token (cask) | $locked | $latest |"$'\n'
  fi
done <<<"$(jq -r '.casks | to_entries[] | "\(.key) \(.value)"' "$lock")"

if [ -n "$rows" ]; then
  echo "| package | locked | latest |"
  echo "|---|---|---|"
  printf '%s' "$rows"
fi
