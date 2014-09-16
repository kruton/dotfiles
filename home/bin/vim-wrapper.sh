#!/usr/bin/env bash
#
# Tries to start gvim if it's available else fall back to text vim.
#

if [[ -n $DISPLAY ]] && hash gvim 2> /dev/null; then \
    gvim $*
else \
    vim $*
fi
