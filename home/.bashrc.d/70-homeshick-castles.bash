#!/usr/bin/env bash

# All the castles I want
homeshick clone --quiet --batch git@github.com:kruton/dotfiles
homeshick clone --quiet --batch https://github.com/rcaloras/bash-preexec.git
homeshick clone --quiet --batch https://github.com/Shougo/neobundle.vim.git
homeshick clone --quiet --batch https://github.com/huyz/dircolors-solarized
homeshick clone --quiet --batch https://github.com/powerline/powerline.git
homeshick clone --quiet --batch https://github.com/okraits/j4-make-config
homeshick clone --quiet --batch https://github.com/nornagon/git-rebase-all.git
homeshick clone --quiet --batch https://github.com/autochthe/history.git
homeshick clone --quiet --batch https://github.com/junegunn/fzf.git
homeshick clone --quiet --batch https://github.com/lincheney/fzf-tab-completion.git
homeshick clone --quiet --batch https://github.com/jorgebucaran/fisher.git

#homeshick clone --quiet --batch https://github.com/ndbroadbent/scm_breeze.git
[ -d "$HOME/.homesick/repos/scm_breeze" ] && \
    rm -rf "$HOME/.homesick/repos/scm_breeze"

#homeshick clone --quiet --batch https://github.com/oh-my-fish/oh-my-fish.git
[ -d "$HOME/.homesick/repos/oh-my-fish" ] && \
    rm -rf "$HOME/.homesick/repos/oh-my-fish"

# This project is a total joke; drama spills out onto the git
# repo repeatedly.
#homeshick clone --quiet --batch https://github.com/fisherman/fisherman.git
[ -d "$HOME/.homesick/repos/fisherman" ] && \
    rm -rf "$HOME/.homesick/repos/fisherman"
