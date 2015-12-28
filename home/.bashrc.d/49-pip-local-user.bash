#!/usr/bin/env bash

# For pip local user installations
if [[ -d ${HOME}/.local/bin ]]; then
    export PATH="${HOME}/.local/bin:${PATH}"
fi
