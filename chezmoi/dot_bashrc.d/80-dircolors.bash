#!/usr/bin/env bash

# solarized dircolors
if [[ -d "$HOME/.dircolors-solarized" ]]; then
    if [[ $TERM == *-256color ]]; then
        if hash gdircolors 2> /dev/null; then
            eval "$(gdircolors "$HOME/.dircolors-solarized/dircolors.256dark")"
        elif hash dircolors 2> /dev/null; then
            eval "$(dircolors "$HOME/.dircolors-solarized/dircolors.256dark")"
        fi
    fi
fi
