#!/bin/bash

# macOS System Settings Configuration

echo "Configuring macOS system settings..."

# Disable press-and-hold for keys in favor of key repeat
# This allows holding down a key to repeat it instead of showing accent menu
defaults write -g ApplePressAndHoldEnabled -bool false

# Trackpad: Set tracking speed to maximum (0-3, 3 is fastest)
defaults write -g com.apple.trackpad.scaling -float 3

# Trackpad: Enable tap to click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Free up Ctrl+Space for tmux prefix by disabling "Select the previous input source"
# (AppleSymbolicHotKeys id 60).
# Must be XML plist: the old-style `{enabled = 0; ...}` syntax has no number/bool
# type, so `enabled` lands as the string "0" and macOS falls back to enabled.
defaults write com.apple.symbolichotkeys.plist AppleSymbolicHotKeys -dict-add 60 \
  '<dict><key>enabled</key><false/><key>value</key><dict><key>type</key><string>standard</string><key>parameters</key><array><integer>32</integer><integer>49</integer><integer>262144</integer></array></dict></dict>'

# Japanese IME (Kotoeri): disable predictive candidates and live conversion.
# Predictive candidates cause heavily-learned words to be mis-committed during
# fast typing (random kanji/English appearing mid-sentence); live conversion is
# kept off per preference. Requires logout/login to take effect (esp. macOS Tahoe 26+).
defaults write com.apple.inputmethod.Kotoeri JIMPrefPredictiveCandidateKey -bool false
defaults write com.apple.inputmethod.Kotoeri JIMPrefLiveConversionKey -bool false

# Symbolic hotkeys are read into the runtime at login, so without this the
# Ctrl+Space change stays dormant until the next login (and looks like it worked).
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

echo "macOS settings applied. Ctrl+Space took effect now; the rest (Kotoeri) needs a restart."
echo ""
echo -e "\033[1;33m⚠️  RESTART REQUIRED\033[0m"
echo -e "\033[1;33mSome settings will not take effect until you restart your Mac.\033[0m"
echo -e "\033[1;33mPlease save your work and restart your system now.\033[0m"
