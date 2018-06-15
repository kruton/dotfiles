#!/usr/bin/env bash

if [[ $OSTYPE == darwin* ]]; then
    # Put Homebrew BASH completion in
    if hash brew 2> /dev/null; then \
        if [ -f "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]; then
            # shellcheck source=/dev/null
            . "$(brew --prefix)/etc/profile.d/bash_completion.sh"
        fi
    fi
fi
