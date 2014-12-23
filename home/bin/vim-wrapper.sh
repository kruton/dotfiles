#!/usr/bin/env bash
#
# Tries to start gvim if it's available else fall back to text vim.
#

if [[ -n $DISPLAY ]] && hash gvim 2> /dev/null; then \
    exec gvim --nofork $*
else \
    exec vim $*
fi
