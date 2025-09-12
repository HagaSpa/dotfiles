#!/bin/bash

set -e

echo "Testing settings.sh..."

# Check if script is executable
if test -x ./settings.sh; then
  echo "✓ settings.sh is executable"
else
  echo "✗ settings.sh is not executable"
  exit 1
fi

# Validate script syntax
if bash -n ./settings.sh; then
  echo "✓ settings.sh syntax is valid"
else
  echo "✗ settings.sh has syntax errors"
  exit 1
fi

# Check for required macOS commands
echo "Checking for required macOS commands..."
commands=(
  "defaults"
)

for cmd in "${commands[@]}"; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "✓ Command '$cmd' is available"
  else
    echo "✗ Command '$cmd' is not available"
    exit 1
  fi
done

# Check for proper shebang
if head -n 1 settings.sh | grep -q "#!/bin/bash"; then
  echo "✓ settings.sh has proper shebang"
else
  echo "✗ settings.sh missing or incorrect shebang"
  exit 1
fi

# Execute settings.sh to test actual functionality
echo "Executing settings.sh..."
./settings.sh

# Verify the settings were applied correctly
echo "Verifying ApplePressAndHoldEnabled setting..."
press_hold_setting=$(defaults read -g ApplePressAndHoldEnabled 2>/dev/null || echo "not set")
if [ "$press_hold_setting" = "0" ]; then
  echo "✓ ApplePressAndHoldEnabled is correctly set to false"
else
  echo "✗ ApplePressAndHoldEnabled setting verification failed (value: $press_hold_setting)"
  exit 1
fi

echo "✓ settings.sh test completed successfully"