#!/bin/bash

set -e

echo "Testing link.sh..."

# Check if script is executable
if test -x ./link.sh; then
  echo "✓ link.sh is executable"
else
  echo "✗ link.sh is not executable"
  exit 1
fi

# Validate script syntax
if bash -n ./link.sh; then
  echo "✓ link.sh syntax is valid"
else
  echo "✗ link.sh has syntax errors"
  exit 1
fi

# Test symbolic link creation (in safe mode)
export DRY_RUN=true
./link.sh || true

# Verify all source files exist
echo "Verifying source files exist..."
exit_code=0
while IFS=':' read -r source target; do
  if [ -f "$source" ]; then
    echo "✓ Source file exists: $source"
  else
    echo "✗ Missing source file: $source"
    exit_code=1
  fi
done <<< "$(grep -E '^\s*"[^"]+:[^"]+"\s*$' link.sh | sed 's/[" ]//g')"

if [ $exit_code -eq 0 ]; then
  echo "✓ link.sh test completed successfully"
else
  echo "✗ link.sh test failed - some source files are missing"
  exit 1
fi