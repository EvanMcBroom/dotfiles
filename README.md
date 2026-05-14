# dotfiles

[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE.txt)

These are my dotfiles for \*nix boxes. They're designed to be small, minimally personalized, and easy to read, use, and modify by anyone on any common platform.

It's recommended to read the shortcuts and functions in `.bashrc` and `.vimrc`. To make full use of these, you'll need to install `openssl`, `shred`, `ssh-agent`, and `veracrypt`. Please be aware that `.tmux` will remap the command prefix to `Ctrl-a` to match `screen`, but programs should otherwise behave as expected.

## Quick setup &ndash; if you’ve ran this thing before

```bash
git clone https://github.com/EvanMcBroom/dotfiles && ./dotfiles/setup.sh apply
```

> :pencil2: The personalized `[user]` section in `.gitconfig` is not installed by default.

## ...or do a dry run then apply the install

```bash
git clone https://github.com/EvanMcBroom/dotfiles
cd dotfiles
./setup.sh plan
./setup.sh apply
```