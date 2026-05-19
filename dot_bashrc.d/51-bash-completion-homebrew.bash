#!/usr/bin/env bash

if [[ $OSTYPE == darwin* ]]; then
    # Put Homebrew BASH completion in
    if hash brew 2> /dev/null; then \
        HOMEBREW_PREFIX="$(brew --prefix)"
        if [ -f "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh" ]; then
            # shellcheck source=/dev/null
            . "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh"
        else
            for COMPLETION in "$HOMEBREW_PREFIX/etc/bash_completion.d/"*; do
                # shellcheck source=/dev/null
                [[ -r $COMPLETION ]] && . "$COMPLETION"
            done
        fi
    fi
fi
