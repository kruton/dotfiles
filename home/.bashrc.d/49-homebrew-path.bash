#!/usr/bin/env bash

# Put Homebrew in the PATH
if [[ $OSTYPE == darwin* && -d /opt/homebrew ]]; then
    export PATH=/opt/homebrew/bin:/opt/homebrew/sbin:$PATH
fi
