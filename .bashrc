# Executed for interactive non-login shells

## Environment
# Set the data directory if it is not already set
if [[ -z "$DATA_DIR" ]]; then
    export DATA_DIR=~/.local
    mkdir -p $DATA_DIR
fi
[ -d "$DATA_DIR/bin" ] && export PATH=$PATH:$DATA_DIR/bin
# Do not include your user or group name when creating a tar archive
export TAR_OPTIONS="--numeric-owner --owner=0 --group=0"
# Prompt format: coffee-icon [terminal] username@short-hostname#/$
export PS1="☕ [\l] \u@\h\\$\[$(tput sgr0)\] "
# Set the default editor to vim
export VISUAL=vim
export EDITOR="$VISUAL"
export SUDO_EDITOR="$VISUAL"
# Set the language
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
# Set the history file location and output format
export HISTTIMEFORMAT="%F %T %Z "
[ $SUDO_USER ] && export HISTFILE="$HOME/.bash_${SUDO_USER}_history"

## Colored output
export CLICOLOR=1 # Enable colors for ls on FreeBSD and macOS
if grep --color=always --help >/dev/null 2>&1; then
    alias egrep='egrep --color=always'
    alias fgrep='fgrep --color=always'
    alias grep='grep --color=always'
fi
alias less="less -R" # Enable colors for less
if ls --color=auto -d . >/dev/null 2>&1; then
    alias ls="ls --color=auto" # Enable colors for GNU environments
elif ls -G -d . >/dev/null 2>&1; then
    alias ls="ls -G" # Enable colors for BSD environments
fi
# Enable the Nord color scheme for ls output. This should work work well with most dark terminal backgrounds
[ -x "$(command -v dircolors)" ] && [ -r ~/.dircolors ] && eval "$(dircolors -b ~/.dircolors)"

## Shortcuts
alias 7z="7z a -mhe=on -p" # Encrypt the archive header and data
alias ll="ls -alhF"
alias p="pwd"
alias ssh-keygen="ssh-keygen -C'' -P''" # Do not include a comment or passphrase in keys
alias umount="sync && umount" # Ensure that writes are complete before unmounting
alias vi="vim"

## Shortcuts with backup logic for missing tool arguments
# rm: prevent / from being recursively removed
rm_preserve_root () { # May not be named 'rm', otherwise 'source' errors
    if command rm --preserve-root --help >/dev/null 2>&1; then
        command rm --preserve-root "$@"
        return
    fi
    local arg
    for arg in "$@"; do
        if [ "$arg" = "/" ]; then
            echo "rm: refusing to remove '/'"
            return 1
        fi
    done
    command rm "$@"
}
alias rm="rm_preserve_root"

## Shortcuts set for platform specific tools
# fw
if command -v iptables &>/dev/null; then alias fw="iptables -nvL --line-numbers";
elif command -v nft &>/dev/null; then alias fw="nft list ruleset";
elif command -v pfctl &>/dev/null; then alias fw="pfctl -sr"; fi
# serv
if command -v python3 &>/dev/null; then alias serv="python3 -m http.server";
elif command -v python2 &>/dev/null; then alias serv="python2 -m SimpleHTTPServer"; fi
# update
if command -v apt-get &>/dev/null; then alias update="apt-get update && apt-get upgrade";
elif command -v brew &>/dev/null; then alias update="brew update && brew upgrade";
elif command -v pkg &>/dev/null; then alias update="pkg update && pkg upgrade";
elif command -v pkgin &>/dev/null; then alias update="pkgin update && pkgin full-upgrade";
elif command -v pkg_add &>/dev/null; then alias update="pkg_add -u"; fi

## Shortcuts set for optionally installed tools
command -v bat &>/dev/null && alias cat="bat" # github.com/sharkdp/bat
command -v htop &>/dev/null && alias top="htop"
command -v proxychains4 &>/dev/null && alias proxy="proxychains4" # github.com/sharkdp/bat
command -v rsync &>/dev/null && {
    alias cpp="rsync -aP" # cp with a progress bar
    alias mvp="rsync -aP --remove-source-files" # mv with a progress bar
}
command -v screen &>/dev/null && alias screen="screen -U" # Run in UTF-8 mode
command -v tldr &>/dev/null && alias man="tldr" # github.com/tldr-pages/tldr
command -v tmux &>/dev/null && alias tmux="tmux -u" # Run in UTF-8 mode
command -v wget &>/dev/null && alias wget="wget -c" # Allow for downloads to be restarted

## Functions

# Reset the host to a clean state
#
# Options:
#   --no-logs  Skip log cleanup
#   --shutdown Shutdown after cleanup
#   --root     Cleanup root when $SUDO_USER is set, not the real user
cleanup () {
    # Process optional arguments
    local clean_logs="true"
    local root_only="false"
    local shutdown_after="false"
    while [ $# -gt 0 ]; do
        case "$1" in
            --no-logs)
                clean_logs="false"
                ;;
            --root)
                root_only="true"
                ;;
            --shutdown)
                shutdown_after="true"
                ;;
            -h|--help)
                echo "Usage: cleanup [--no-logs] [--root] [--shutdown]"
                return 0
                ;;
            *)
                echo "Usage: cleanup [--no-logs] [--root] [--shutdown]"
                return 1
                ;;
        esac
        shift
    done

    local docker_status="skipped"
    local firewall_status="skipped"
    local history_status="skipped"
    local logs_status="skipped"
    if [ "$EUID" -eq 0 ]; then
        # https://stackoverflow.com/a/1885534/11039217
        echo "About to reset to a clean state."
        read -p "Are you sure you want to continue [y/N]? " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Clear command history
            unset HISTFILE HISTFILESIZE HISTSIZE
            history -c
            # Tear down local containers before resetting networking state.
            if command -v docker &>/dev/null; then
                docker ps -q | while read -r container; do [ -n "$container" ] && docker kill "$container"; done # Stop all docker containers
                docker ps -a -q | while read -r container; do [ -n "$container" ] && docker rm "$container"; done # Remove all docker containers
                docker images -q | while read -r image; do [ -n "$image" ] && docker rmi "$image"; done # Remove all docker images
                docker_status="done"
            fi
            # Reset whichever firewall stack this host is using.
            if command -v iptables &>/dev/null; then
                iptables -P INPUT ACCEPT
                iptables -P OUTPUT ACCEPT
                iptables -P FORWARD ACCEPT
                iptables -F
                iptables -t nat -F 2>/dev/null
                iptables -t mangle -F 2>/dev/null
                iptables -t raw -F 2>/dev/null
                firewall_status="done"
            fi
            if command -v ip6tables &>/dev/null; then
                ip6tables -P INPUT ACCEPT
                ip6tables -P OUTPUT ACCEPT
                ip6tables -P FORWARD ACCEPT
                ip6tables -F
                ip6tables -t mangle -F 2>/dev/null
                ip6tables -t raw -F 2>/dev/null
                firewall_status="done"
            fi
            if command -v nft &>/dev/null; then
                nft flush ruleset
                firewall_status="done"
            fi
            if command -v pfctl &>/dev/null; then
                pfctl -F all 2>/dev/null
                firewall_status="done"
            fi
            # Optionally clean logs
            local logs_touched="false"
            if [ "$clean_logs" = "true" ]; then
                # Clear all runtime logs
                if [ -d "/var/log" ]; then
                    echo "y" | shredder /var/log
                    logs_touched="true"
                fi
                # Clear journalctl
                if command -v journalctl &>/dev/null; then
                    journalctl --rotate >/dev/null 2>&1
                    journalctl --vacuum-time=1s >/dev/null 2>&1
                    logs_touched="true"
                fi
                # Clear macOS unified logs
                if command -v log &>/dev/null && log erase --all >/dev/null 2>&1; then
                    logs_touched="true"
                fi
                [ "$logs_touched" = "true" ] && logs_status="done"
            else
                logs_status="skipped (--no-logs)"
            fi
            # Clear the kernel ring buffer
            if dmesg -C >/dev/null 2>&1; then dmesg -C >/dev/null;
            elif dmesg -c >/dev/null 2>&1; then dmesg -c >/dev/null; fi
            # Remove shell history artifacts
            local sudo_home=""
            if [ "$root_only" != "true" ] && [ -n "$SUDO_USER" ]; then
                # Get real user
                if command -v getent &>/dev/null; then
                    sudo_home="$(getent passwd "$SUDO_USER" | cut -d: -f6)"
                elif command -v dscl &>/dev/null; then
                    sudo_home="$(dscl . -read "/Users/$SUDO_USER" NFSHomeDirectory 2>/dev/null | awk '{print $2}')"
                elif command -v pw &>/dev/null; then
                    sudo_home="$(pw usershow "$SUDO_USER" 2>/dev/null | awk -F: '{print $9}')"
                fi
            fi
            # Remove shell history artifacts
            local history_home=""
            local history_touched="false"
            for history_home in "$HOME" "$sudo_home"; do
                [ -n "$history_home" ] || continue
                local history_file=""
                for history_file in "$history_home"/.*history "$history_home"/.*hst* "$history_home"/.*info; do
                    [ -f "$history_file" ] || continue
                    history_touched="true"
                    if command -v shred &>/dev/null; then
                        shred -f "$history_file"
                    else
                        command rm -f "$history_file"
                    fi
                done
            done
            [ "$history_touched" = "true" ] && history_status="done"
            # Output cleanup summary
            echo "Cleanup summary:"
            echo "  Docker  : $docker_status"
            echo "  Firewall: $firewall_status"
            echo "  History : $history_status"
            echo "  Logs    : $logs_status"
            echo "  Shutdown: $shutdown_after"
            sync # Complete all writes
            # Optionally shutdown
            [ "$shutdown_after" = "true" ] && shutdown -h now
        fi
    else
        echo "Must be ran as root."
    fi
}

# Export crypt, log, and note files in $DATA_DIR
# to an ISO 8601 time stamped archive in $HOME
data-export () {
    local data_path=""
    local export_paths=()
    for data_path in crypt logs notes; do
        [ -e "$DATA_DIR/$data_path" ] && export_paths+=("$data_path")
    done

    if [ "${#export_paths[@]}" -eq 0 ]; then
        echo "Nothing to export from $DATA_DIR."
        return 1
    fi

    local archive_path="$HOME/$(date '+%Y-%m-%dT%H%M%S%z').tar.gz"
    tar -C "$DATA_DIR" -czf "$archive_path" "${export_paths[@]}" && echo "$archive_path"
}

# Import crypt, log, and note files from a previous
# data export archive to $DATA_DIR
data-import () {
    local archive_path="$1"
    if [ -z "$archive_path" ]; then
        echo "Usage: data-import <archive-path>"
        return 1
    elif [ ! -f "$archive_path" ]; then
        echo "Archive not found: $archive_path"
        return 1
    fi

    mkdir -p "$DATA_DIR"
    tar -C "$DATA_DIR" -xzf "$archive_path" && echo "$DATA_DIR"
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

# Start an ISO 8601 time stamped terminal logging session
# Used 'exit' to end the session
log () {
    mkdir -p "$DATA_DIR/logs/"
    script "$DATA_DIR/logs/$(date '+%Y-%m-%dT%H%M%S%z').log"
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
            if command -v shred &>/dev/null; then
                find "$last_arg" -type f -print0 | while IFS= read -r -d '' file; do shred $other_args "$file"; done
            else
                echo "Warning: shred not installed; deleting files without secure overwrite."
                find "$last_arg" -type f -exec rm -f {} +
            fi
            rm -rf "$last_arg"
        fi
    else
        echo "shredder [OPTION]... DIR"
    fi
}

# Create, ls, mount, and unmount veracrypt volumes
# The $DATA_DIR/crypt directory will be used by default
vc () {
    # FAT is used for universal support
    # exFAT is preferred by fails on WSL2 per VeraCrypt/issues/1464
    local filesystem="FAT"

    local vc_bin
    if command -v veracrypt &>/dev/null; then
        vc_bin="$(command -v veracrypt)"
    elif [ -x "/Applications/VeraCrypt.app/Contents/MacOS/VeraCrypt" ]; then
        vc_bin="/Applications/VeraCrypt.app/Contents/MacOS/VeraCrypt"
    elif [ ! -x "$vc_bin" ]; then
        echo "VeraCrypt is not installed."
        return 1
    fi

    local subcommand
    if [ $# -eq 0 ]; then
        subcommand="help"
    else
        subcommand="$1"
        shift
    fi

    local crypt_dir="$DATA_DIR/crypt"
    local mount_dir="$DATA_DIR/mnt"
    local volume_path mount_path password password2 size random_source
    case "$subcommand" in
            ""|help|-h|--help)
            cat << EOF
Usage:
  vc create <name|path> [size]
  vc ls
  vc mount <name|path> [mount-path]
  vc unmount [name|path|mount-path|all]
EOF
            return 0
            ;;
        create)
            [ -z "$1" ] && {
                echo "Usage: vc create <name|path> [size]"
                return 1
            }
            mkdir -p "$crypt_dir"
            if [[ "$1" = */* ]]; then
                volume_path="$1"
            else
                volume_path="$crypt_dir/${1%.vc}.vc"
            fi
            size="$2"
            [ -z "$size" ] && read -p "Size (ex. 200M or 5G): " size
            read -s -p "Password: " password
            echo
            read -s -p "Confirm password: " password2
            echo
            [ "$password" != "$password2" ] && echo "Passwords do not match." && return 1
            [ -r /dev/urandom ] && random_source="--random-source /dev/urandom"
            # Based on the Arcane Code command-line examples for Unix platforms.
            sudo "$vc_bin" --text --create "$volume_path" --size "$size" --password "$password" --volume-type normal --encryption AES --hash sha-512 --filesystem "$filesystem" --pim 0 --keyfiles "" ${random_source}
            ;;
        ls|list)
            sudo "$vc_bin" --text --list
            ;;
        mount)
            [ -z "$1" ] && {
                echo "Usage: vc mount <name|path> [mount-path]"
                return 1
            }
            mkdir -p "$crypt_dir" "$mount_dir"
            if [[ "$1" = */* ]]; then
                volume_path="$1"
            else
                volume_path="$crypt_dir/${1%.vc}.vc"
            fi
            [ ! -e "$volume_path" ] && echo "Volume not found: $volume_path" && return 1
            mount_path="$2"
            [ -z "$mount_path" ] && mount_path="$mount_dir/$(basename "$volume_path" .vc)"
            mkdir -p "$mount_path"
            read -s -p "Password: " password
            echo
            sudo "$vc_bin" --text -m=nokernelcrypto --mount "$volume_path" "$mount_path" --password "$password" --pim 0 --keyfiles "" --protect-hidden no
            ;;
        unmount|umount)
            if [ -z "$1" ] || [ "$1" = "all" ]; then
                sudo "$vc_bin" --text --unmount
            else
                if [[ "$1" = */* ]]; then
                    volume_path="$1"
                elif [ -e "$crypt_dir/${1%.vc}.vc" ]; then
                    volume_path="$crypt_dir/${1%.vc}.vc"
                else
                    volume_path="$1"
                fi
                sudo "$vc_bin" --text --unmount "$volume_path"
            fi
            ;;

        *)
            echo "Unknown subcommand: $subcommand"
            vc help
            return 1
            ;;
    esac
}
