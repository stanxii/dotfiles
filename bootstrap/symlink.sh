#!/usr/bin/env bash
set -e

# Basic symlinks, safe to run on any system

# initialize script and dependencies -------------------------------------------
# get this bootstrap folder
cd "$(dirname "$0")"/..
dotfiles_path="$(pwd)"
bootstrap_path="$dotfiles_path/bootstrap"
source "$bootstrap_path/helpers.sh"

# begin ------------------------------------------------------------------------
dkostatus "Symlinking dotfiles"
dkosymlink aspell/.aspell.en.pws.symlink        .aspell.en.pws
dkosymlink ctags/.ctags.symlink                 .ctags
dkosymlink mdl/.mdlrc.symlink                   .mdlrc
dkosymlink ruby/.gemrc.symlink                  .gemrc

# XDG-compatible
dkosymlink git/.gitconfig.symlink               .config/git/config
dkosymlink shell/.inputrc.symlink               .config/readline/inputrc

# irssi
dkosymlink irssi                                .irssi

# (n)vim
dkosymlink vim                                  .vim
dkosymlink vim                                  .config/nvim
dkosymlink aspell/.aspell.en.pws.symlink        .vim/aspell.utf-8.add

case "$OSTYPE" in
  darwin*)
    dkosymlink subversion/config.symlink        .subversion/config
    ;;
  linux*)
    dkosymlink linux/subversion/config.symlink  .subversion/config
    dkosymlink linux/x/.Xresources              .Xresources
    ;;
esac


# symlink shells ---------------------------------------------------------------
dkosymlink bash/.bashrc.symlink                 .bashrc
dkosymlink bash/.bash_profile.symlink           .bash_profile
dkosymlink zsh/.zshenv.symlink                  .zshenv

dkostatus "Done! [symlink.sh]"
