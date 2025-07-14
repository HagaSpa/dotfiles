#!/bin/sh

# Get the script directory to ensure correct paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> $HOME/.zprofile

# Source brew environment if it exists
if [ -f "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# install via brew using absolute path to Brewfile
brew bundle --file="$SCRIPT_DIR/Brewfile"

# gcloud
cd $HOME
curl -OL https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-454.0.0-darwin-arm.tar.gz
tar -xvf google-cloud-cli-454.0.0-darwin-arm.tar.gz 
cd google-cloud-sdk
yes | ./install.sh

