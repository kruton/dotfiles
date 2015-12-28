#!/usr/bin/env bash

# Put Homebrew in the PATH
if [[ $OSTYPE == darwin* ]]; then
    export PATH=/usr/local/bin:/usr/local/sbin:$PATH
fi
