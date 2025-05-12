#!/usr/bin/env bash

if [[ $OSTYPE == darwin* && -n $MP_PREFIX ]]; then
    # Put MacPorts BASH completion in
    if [ -f "$MP_PREFIX/etc/profile.d/bash_completion.sh" ]; then
        # shellcheck source=/dev/null
        . "$MP_PREFIX/etc/profile.d/bash_completion.sh"
    fi

    if [ -f "$MP_PREFIX/share/git/contrib/completion/git-completion.bash" ]; then
        # shellcheck source=/dev/null
        . "$MP_PREFIX/share/git/contrib/completion/git-completion.bash"
    fi
fi
