#!/bin/bash

error() {
  echo "$1"
  exit
}

# The script's directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check for git and tmux
git --version 2>&1 >/dev/null
[ $? -ne 0 ] && error "Install git"
tmux -V 2>&1 >/dev/null
[ $? -ne 0 ] && error "Install git"

# Install pathogen
mkdir -p ~/.vim/autoload ~/.vim/bundle
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# Install pathogen bundles
pushd ~/.vim/bundle
git -C nerdtree pull || git clone https://github.com/scrooloose/nerdtree
git -C syntastic pull || git clone https://github.com/scrooloose/syntastic
git -C vim-airline pull || git clone https://github.com/bling/vim-airline
git -C vim-airline-themes pull || git clone https://github.com/vim-airline/vim-airline-themes
git -C vim-colors-solarized pull || git clone https://github.com/altercation/vim-colors-solarized
git -C vim-fugitive pull || git clone https://github.com/tpope/vim-fugitive
popd

# Install dotfiles
pushd ~/
[ -f .bash_profile ] && mv .bash_profile .bash_profile.bck
cp $DIR/.bash_profile .bash_profile
[ -f .bashrc ] && mv .bashrc .bashrc.bck
[ -f .gitconfig ] && mv .gitconfig .gitconfig.bck
cp $DIR/.gitconfig .gitconfig
[ -f .gitignore_global ] && mv .gitignore_global .gitignore_global.bck
cp $DIR/.gitignore_global .gitignore_global
[ -f .tmux.conf ] && mv .tmux.conf .tmux.conf.bck
cp $DIR/.tmux.conf .tmux.conf
[ -f .vimrc ] && mv .vimrc .vimrc.bck
cp $DIR/.vimrc .vimrc
popd
