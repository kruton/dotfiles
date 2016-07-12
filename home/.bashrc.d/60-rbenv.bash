#!/usr/bin/env bash

# rbenv - Ruby Environment Manager

if [ -d "$HOME/.rbenv/bin" ]; then
    export PATH="$PATH:$HOME/.rbenv/bin"
fi

if [ -d "$HOME/.ruby-build/bin" ]; then
    export PATH="$PATH:$HOME/.ruby-build/bin"
fi

if hash rbenv 2> /dev/null; then \
    eval "$(rbenv init -)"
fi
