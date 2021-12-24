#!/bin/bash

# The directory this script is in
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Script name
SCRIPT_NAME=`basename "$0"`

help_message () {
    cat << EOF
Commands:
  validate  Check whether the dotfiles were installed
  plan      Show changes required to install dotfiles
  apply     Create a backup then install dotfiles
  destroy   Restore dotfiles from the backup
EOF
    exit 1
}

if [ $# -eq 0 ]; then # No arguments
    help_message
elif [ $1 = "apply" ]; then
    mkdir -p ~/.dotfiles
    echo "$SCRIPT_NAME: Backing up..."
    for file in $(find ~ -maxdepth 1 -type f -name ".*"); do
        echo "~/$(basename $file) -> ~/.dotfiles/$(basename $file).bck"
        mv $file "$HOME/.dotfiles/$(basename $file).bck"
    done
    printf "\n$SCRIPT_NAME: Adding...\n"
    for file in $(find $DIR -maxdepth 1 -type f -name ".*" -not -name ".gitattributes"); do
        echo "$(basename $file) -> ~/$(basename $file)"
        cp $file ~
    done
elif [ $1 = "destroy" ]; then
    if [ -d "$HOME/.dotfiles" ]; then
        find ~ -maxdepth 1 -type f -name ".*" | xargs -i{} rm {}
        for file in $(find ~/.dotfiles -maxdepth 1 -type f -name ".*.bck"); do
            mv $file "$HOME/$(basename ${file::-4})"
        done
        rmdir "$HOME/.dotfiles"
    else
        echo "The backup ~/.dotfiles directory does not exist."
    fi
elif [ $1 = "plan" ]; then
    original=$(find ~ -maxdepth 1 -type f -name ".*")
    new=$(find $DIR -maxdepth 1 -type f -name ".*" -not -name ".gitattributes")
    printf "\nPlan: $(echo $original | wc -w) to backup, $(echo $new | wc -w) to add\n"
    printf "\n$SCRIPT_NAME: Backing up...\n"
    for file in $original; do echo "~/$(basename $file) -> ~/.dotfiles/$(basename $file).bck"; done
    printf "\n$SCRIPT_NAME: Adding...\n"
    for file in $new; do echo "$(basename $file) -> ~/$(basename $file)"; done
elif [ $1 = "validate" ]; then
    valid="true"
    # Execute the loop in the same shell to be about to set the "valid" variable
    # https://stackoverflow.com/a/16855194/11039217
    while read file; do
        file2="$HOME/$(basename $file)"
        if [ ! -f $file2 ]; then
            echo "Error: Missing dotfile $(basename $file)" && valid="false" && break
        elif ! cmp -s $file $file2; then
            echo "Error: The $(basename $file) dotfiles do not match" && valid="false" && break
        fi
    done < <(find $DIR -maxdepth 1 -type f -name '.*' -not -name '.gitattributes')
    [ $valid = "true" ] && echo "Success! The configuration is valid."
else
    help_message
fi
