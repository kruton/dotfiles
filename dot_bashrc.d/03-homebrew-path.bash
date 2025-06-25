#!/usr/bin/env bash

_add_homebrew_path() {
    local hb_path
    [ -d /opt/homebrew ] && hb_path=/opt/homebrew
    [ -d $HOME/homebrew ] && hb_path=$HOME/homebrew

    [[ -z $hb_path ]] && return

    export PATH=$hb_path/bin:$hb_path/sbin:$PATH

    # For dircolors, etc
    [ -d $hb_path/opt/coreutils/libexec/gnubin ] &&
        export PATH=$hb_path/opt/coreutils/libexec/gnubin:$PATH
}

# Put Homebrew in the PATH
if [[ $OSTYPE == darwin* ]]; then \
    _add_homebrew_path
fi

unset _add_homebrew_path
