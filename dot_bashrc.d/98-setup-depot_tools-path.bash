#!/usr/bin/env bash
#
# Chromium depot_tools setup script. Should come last!

if [[ -d "${HOME}/depot_tools" ]]; then
    export PATH="$HOME/depot_tools:$PATH"
fi
