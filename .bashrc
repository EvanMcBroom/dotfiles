# Executed for interactive non-login shells

## Environment
# Set the data directory if it is not already set
if [[ -z "$DATA_DIR" ]]; then
    export DATA_DIR=~/.local
    mkdir -p $DATA_DIR
fi
# Do not include your user or group name when creating a tar archive
export TAR_OPTIONS="--numeric-owner --owner=0 --group=0"
# Prompt format: coffee-icon [terminal] username@short-hostname#/$
export PS1="☕ [\l] \u@\h\\$\[$(tput sgr0)\] "
# Set the default editor to vim
export VISUAL=vim
export EDITOR="$VISUAL"
# Set the language
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

## Colored output
export CLICOLOR=1 # Enable colors for ls on FreeBSD and macOS
export GREP_OPTIONS='--color=always' # Enable colors for [e|f]grep in a way that can be disabled
alias less="less -R" # Enable colors for less
alias ls="ls --color=auto" # Enable colors for GNU environments

## Shortcuts
alias 7z="7z a -mhe=on -p" # Encrypt the archive header and data
alias fw="iptables -nvL --line-numbers"
alias ll="ls -alhF"
alias p="pwd"
alias rm="rm --preserve-root" # Prevent / from being recursively removed
alias ssh-keygen="ssh-keygen -C'' -P''" # Do not include a comment or passphrase in keys
alias umount="sync && umount" # Ensure that writes are complete before unmounting
alias update="apt-get update || apt-get upgrade" # Try to update package information then upgrade
alias vi="vim"

## Shortcuts for optional tools
command -v bat &>/dev/null && alias cat="bat" # github.com/sharkdp/bat
command -v htop &>/dev/null && alias top="htop"
command -v proxychains4 &>/dev/null && alias proxy="proxychains4" # github.com/sharkdp/bat
if command -v python3 &>/dev/null; then alias serv="python3 -m http.server";
elif command -v python2 &>/dev/null; then alias serv="python2 -m SimpleHTTPServer"; fi
command -v rsync &>/dev/null && {
    alias cpp="rsync -aP" # cp with a progress bar
    alias mvp="rsync -aP --remove-source-files" # mv with a progress bar
}
command -v screen &>/dev/null && alias screen="screen -U" # Run in UTF-8 mode
command -v tldr &>/dev/null && alias man="tldr" # github.com/tldr-pages/tldr
command -v tmux &>/dev/null && alias tmux="tmux -u" # Run in UTF-8 mode
command -v wget &>/dev/null && alias wget="wget -c" # Allow for downloads to be restarted

## Functions

clean () {
    if [ "$EUID" -eq 0 ]; then
        # https://stackoverflow.com/a/1885534/11039217
        echo "About to reset to a clean state and shutdown."
        read -p "Are you sure you want to continue [y/N]? " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker ps -q | xargs -i{} docker kill {} # Stop all docker containers
            docker ps -a -q | xargs -i{} docker rm {} # Remove all docker containers
            docker images -q | xargs -i{} docker rmi {} # Remove all docker images
            # Clear iptables for IPv4
            iptables -P INPUT ACCEPT
            iptables -P OUTPUT ACCEPT
            iptables -F
            # Clear iptables for IPv6
            ip6tables -P INPUT ACCEPT
            ip6tables -P OUTPUT ACCEPT
            ip6tables -F
            [ -d "/var/log" ] && echo "y" | shredder /var/log # Clear all runtime logs
            dmesg -C # Clear the kernel ring buffer
            find ~ -maxdepth 1 \( -name ".*history" -o -name ".*hst*" -o -name ".*info" \) | xargs -i{} rm -f {} # Clear user history
            sync # Complete all writes
            shutdown -h now
        fi
    else
        echo "Must be ran as root."
    fi
}

# Generate a random password
# If OpenSSL is installed generate the shadow hash as well
genpass () {
    password=$(tr -dc a-zA-Z0-9 < /dev/urandom | head -c 12)
    echo "Password: $password"
    if command -v openssl &> /dev/null; then
        # https://unix.stackexchange.com/a/81248
        salt=$(tr -dc a-z < /dev/urandom | head -c 3)
        printf "Shadow hash: %s\n" "$(openssl passwd -6 -salt $salt $password)"
    fi
}

# Start an ssh agent if needed and show the currently loaded keys
keys () {
    # https://stackoverflow.com/a/38619604/11039217
    if [ ! -S "$DATA_DIR/.ssh_auth_sock" ]; then
        eval `ssh-agent`
        ln -sf "$SSH_AUTH_SOCK" "$DATA_DIR/.ssh_auth_sock"
    fi
    export SSH_AUTH_SOCK="$DATA_DIR/.ssh_auth_sock"
    ssh-add -l
}

# Create and open a Markdown file for taking notes
# Name the file similar to Obsidian's Zettelkasten plugin
note () {
    mkdir -p "$DATA_DIR/notes/"
    # https://stackoverflow.com/a/1401495/11039217
    file="$DATA_DIR/notes/$(date '+%Y-%m-%d').md"
    if [ ! -f $file ]; then
        # Example date for the format in the note template: Monday, January 1 at  1:00 AM UTC
        printf '# %s\n\nProject(s): \n\n## Progress\n\n' "$(date +'%A, %B %d at %l:%M %p %Z')" > $file
    fi
    vim $file
}

# Shred recursively (shred - 'dir')
shredder () {
    # https://stackoverflow.com/a/33271194/11039217
    last_arg=${@:$#}
    other_args=${*%${!#}}
    if [[ -d $last_arg ]]; then
        # https://stackoverflow.com/a/1885534/11039217
        echo "About to recursively shred: $last_arg"
        read -p "Are you sure you want to continue [y/N]? " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            find $last_arg -type f | xargs -i{} shred $other_args {}
            rm -rf $last_arg
    fi
    else
        echo "shredder [OPTION]... DIR"
    fi
}
