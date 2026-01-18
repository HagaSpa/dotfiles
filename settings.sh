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

echo "macOS settings applied. Please restart your system for all changes to take effect."
echo ""
echo -e "\033[1;33m⚠️  RESTART REQUIRED\033[0m"
echo -e "\033[1;33mSome settings will not take effect until you restart your Mac.\033[0m"
echo -e "\033[1;33mPlease save your work and restart your system now.\033[0m"