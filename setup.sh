#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi

# The script's directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Install git, tmux, and zsh
apt-get -y install --upgrade git
apt-get -y install --upgrade tmux
apt-get -y install --upgrade zsh

# Set the login shell to zsh
sudo chsh -s $(which zsh) $SUDO_USER

# Drop privileges
sudo su -c "$DIR/unprivileged-setup.sh" - $SUDO_USER
