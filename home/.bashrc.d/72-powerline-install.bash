#!/bin/bash

# installs powerline if not installed

if [[ ! -x $HOME/.local/bin/powerline ]]; then \
    pip install --user --editable="$HOME/.homesick/repos/powerline"
    if command -v pip3 > /dev/null 2>&1; then \
        pip3 install --user --editable="$HOME/.homesick/repos/powerline"
    fi
fi
