#!/bin/sh

cd $HOME

# install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> $HOME/.zprofile

# install via brew
brew bundle --file=./Brewfile

# gcloud
curl -OL https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-454.0.0-darwin-arm.tar.gz
tar -xvf google-cloud-cli-454.0.0-darwin-arm.tar.gz 
z google-cloud-sdk
yes | ./install.sh

# Hack Nerd Font
# cp  Hack Regular Nerd Font Complete.ttf ~/Library/Fonts
