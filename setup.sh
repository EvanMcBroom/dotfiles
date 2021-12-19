#!/bin/bash

# The script's directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Install pathogen
mkdir -p ~/.vim/autoload ~/.vim/bundle
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# Install pathogen bundles
pushd ~/.vim/bundle
git -C nerdtree pull 2>/dev/null || git clone https://github.com/scrooloose/nerdtree
git -C syntastic pull 2>/dev/null || git clone https://github.com/scrooloose/syntastic
git -C vim-airline pull 2>/dev/null || git clone https://github.com/bling/vim-airline
git -C vim-airline-themes pull 2>/dev/null || git clone https://github.com/vim-airline/vim-airline-themes
git -C vim-colors-solarized pull 2>/dev/null || git clone https://github.com/altercation/vim-colors-solarized
git -C vim-fugitive pull 2>/dev/null || git clone https://github.com/tpope/vim-fugitive
popd

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sed -e 's/env zsh//g')" 
cp $DIR/evanmcbroom.zsh-theme .oh-my-zsh/custom/evanmcbroom.zsh-theme # Add my oh-my-zsh theme

# Get current dircolors-solarized
curl -LSso ~/.dircolors https://raw.githubusercontent.com/seebi/dircolors-solarized/master/dircolors.ansi-dark

# Install dotfiles
pushd ~/
[ -f .aliases ] && mv .aliases .aliases.bck
cp $DIR/.aliases .aliases
[ -f .bash_profile ] && mv .bash_profile .bash_profile.bck
cp $DIR/.bash_profile .bash_profile
[ -f .bashrc ] && mv .bashrc .bashrc.bck
cp $DIR/.bashrc .bashrc
[ -f .gitconfig ] && mv .gitconfig .gitconfig.bck
cp $DIR/.gitconfig .gitconfig
[ -f .gitignore_global ] && mv .gitignore_global .gitignore_global.bck
cp $DIR/.gitignore_global .gitignore_global
[ -f .tmux.conf ] && mv .tmux.conf .tmux.conf.bck
cp $DIR/.tmux.conf .tmux.conf
[ -f .vimrc ] && mv .vimrc .vimrc.bck
cp $DIR/.vimrc .vimrc
[ -f .zshrc ] && mv .zshrc .zshrc.bck
cp $DIR/.zshrc .zshrc
popd
