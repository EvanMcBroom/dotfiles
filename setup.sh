#!/usr/bin/env bash

# The directory this script is in
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Script name
SCRIPT_NAME=$(basename "$0")

managed_files=()
for file in "$DIR"/.*; do
    [ -f "$file" ] || continue
    [ "$(basename "$file")" = ".gitattributes" ] && continue
    managed_files+=("$file")
done

gitconfig_without_user_awk='/^\[user\]$/ { skip = 1; next } /^\[/ { skip = 0 } !skip { print }'

help_message () {
    cat << EOF
Commands:
  validate  Check whether the dotfiles were installed
  plan      Show changes required to install dotfiles
  apply     Create a backup then install dotfiles
  destroy   Restore dotfiles from the backup

Options:
  --full    Include the personalized [user] section in .gitconfig
EOF
    exit 1
}


if [ $# -eq 0 ] || [ $# -gt 2 ] || { [ $# -eq 2 ] && [ "$2" != "--full" ]; }; then
    help_message
elif [ $1 = "apply" ]; then
    mkdir -p ~/.dotfiles
    echo "$SCRIPT_NAME: Backing up..."
    for file in "${managed_files[@]}"; do
        target="$HOME/$(basename "$file")"
        backup="$HOME/.dotfiles/$(basename "$file").bck"
        if [ -f "$target" ]; then
            echo "~/$(basename "$file") -> ~/.dotfiles/$(basename "$file").bck"
            mv "$target" "$backup"
        fi
    done
    printf "\n$SCRIPT_NAME: Adding...\n"
    for file in "${managed_files[@]}"; do
        echo "$(basename "$file") -> ~/$(basename "$file")"
        if [ "$(basename "$file")" = ".gitconfig" ] && [ "$2" != "--full" ]; then
            awk "$gitconfig_without_user_awk" "$file" > "$HOME/$(basename "$file")"
        else
            cp "$file" "$HOME"
        fi
    done
    if [ "$2" = "--full" ]; then
        printf "\nNote: Update the user name and email in the .gitconfig file\n"
    else
        printf "\nNote: .gitconfig was installed without the [user] section. Use --full to include it.\n"
    fi
elif [ $1 = "destroy" ]; then
    if [ -d "$HOME/.dotfiles" ]; then
        for file in "${managed_files[@]}"; do
            target="$HOME/$(basename "$file")"
            backup="$HOME/.dotfiles/$(basename "$file").bck"
            [ -f "$target" ] && rm -f -- "$target"
            [ -f "$backup" ] && mv "$backup" "$target"
        done
        rmdir "$HOME/.dotfiles" 2>/dev/null || true
    else
        echo "The backup ~/.dotfiles directory does not exist."
    fi
elif [ $1 = "plan" ]; then
    original=0
    for file in "${managed_files[@]}"; do
        [ -f "$HOME/$(basename "$file")" ] && original=$((original + 1))
    done
    printf "\nPlan: %s to backup, %s to add\n" "$original" "${#managed_files[@]}"
    printf "\n$SCRIPT_NAME: Backing up...\n"
    for file in "${managed_files[@]}"; do
        if [ -f "$HOME/$(basename "$file")" ]; then
            echo "~/$(basename "$file") -> ~/.dotfiles/$(basename "$file").bck"
        fi
    done
    printf "\n$SCRIPT_NAME: Adding...\n"
    for file in "${managed_files[@]}"; do
        if [ "$(basename "$file")" = ".gitconfig" ] && [ "$2" != "--full" ]; then
            echo ".gitconfig (without user section) -> ~/.gitconfig"
        else
            echo "$(basename "$file") -> ~/$(basename "$file")"
        fi
    done
elif [ $1 = "validate" ]; then
    valid="true"
    for file in "${managed_files[@]}"; do
        file2="$HOME/$(basename "$file")"
        if [ ! -f "$file2" ]; then
            echo "Error: Missing dotfile $(basename "$file")" && valid="false" && break
        elif [ "$(basename "$file")" = ".gitconfig" ]; then
            if ! cmp -s "$file" "$file2" && ! cmp -s <(awk "$gitconfig_without_user_awk" "$file") "$file2"; then
                echo "Error: The $(basename "$file") dotfiles do not match" && valid="false" && break
            fi
        elif ! cmp -s "$file" "$file2"; then
            echo "Error: The $(basename "$file") dotfiles do not match" && valid="false" && break
        fi
    done
    [ $valid = "true" ] && echo "Success! The configuration is valid."
else
    help_message
fi
