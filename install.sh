#!/usr/bin/env sh

set -eu

if ! command -v git >/dev/null 2>&1; then
    if command -v apk >/dev/null 2>&1; then sudo apk add git
    elif command -v apt >/dev/null 2>&1; then sudo apt update && sudo apt install -y git
    elif command -v apt-get >/dev/null 2>&1; then sudo apt-get update && sudo apt-get install -y git
    elif command -v dnf >/dev/null 2>&1; then sudo dnf install -y git
    elif command -v pacman >/dev/null 2>&1; then sudo pacman -Sy --noconfirm git
    elif command -v yum >/dev/null 2>&1; then sudo yum install -y git
    elif command -v zypper >/dev/null 2>&1; then sudo zypper --non-interactive install git
    else
        echo "No supported package manager found; install git and rerun this script." >&2
        exit 1
    fi
fi

repo="$HOME/.dotfiles"
if [ -d "$repo/.git" ]; then
    git -C "$repo" pull --ff-only
else
    git clone https://github.com/EvanMcBroom/dotfiles "$repo"
fi
"$repo/setup.sh" apply
