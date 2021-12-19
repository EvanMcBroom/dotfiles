# Executed for interactive non-login shells

## Environment
# Do not include your user or group name when creating a tar archive
export TAR_OPTIONS=--numeric-owner\ --owner=0\ --group=0
# Username:[light blue]CWD:[yellow]git indicator:[red]error code$
export PS1="\u:\[\e[36m\]\W\[\e[m\]:\[\e[33m\]\`parse_git_branch\`\[\e[m\]:\[\e[31m\]\`nonzero_return\`\[\e[m\]\[\e[36m\]\\$\[\e[m\] "
# Set the default editor to vim
export VISUAL=vim
export EDITOR="$VISUAL"

## Colored output
export CLICOLOR=1 # Enable colors for ls on FreeBSD and macOS
alias grep=grep\ --color=always
alias less=less -R
alias ls=ls\ --color=auto # Enable colors for GNU environments

## Shortcuts
alias 7z=7z\ a\ -mhe=on\ -p # Encrypt the archive header and data
if command -v bat &> /dev/null; then alias cat=bat; fi # github.com/sharkdp/bat
alias ll=ls\ -alhF
if command -v tldr &> /dev/null; then alias man=tldr; fi # github.com/tldr-pages/tldr
alias ssh-keygen=ssh-keygen -C '' -P '' # Do not include a comment or passphrase
alias umount=sync\ &&\ umount # Ensure that writes are complete before unmounting
alias vi=vim

## Functions
get () {

}

# Create and open a Markdown file for note
# Name the file similar to Obsidian's Zettelkasten plugin
notes () {
20200101
}

put () {
    put and get for ssh with -i
}

# Shred recursively (shred - 'dir')
shredder () {
    # https://stackoverflow.com/a/33271194/11039217
    last_arg=${@:$#}
    other_args=${*%${!#}}
    if [[ -d $last_arg ]]; then
        # https://stackoverflow.com/a/1885534/11039217
        echo "About to recursively shred: $last_arg"
        read -p "Are you sure you want to continue [y/N]? " -n 1 -r
        echo # move to a new line
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            find $last_arg -type f | xargs -i {} shred $other_args {}
            rm -rf $last_arg
        else
    else
        echo "shredder [OPTION]... DIR"
        exit 1
    fi
}