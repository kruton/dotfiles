#!/usr/bin/env bash

# This runs all the things that want to use preexec-like functionality

function preexec() {
    local cmd="$1"
    if type -t _mrg_ec > /dev/null; then
        _mrg_ec
    fi
    if [[ $TERM_PROGRAM != Apple_Terminal && ( $TERM == xterm* || $TERM == screen* ) ]]; then
        _preexec_title "$cmd"
    fi
}

function precmd() {
    local last_exit_code=$?
    local cmd="$1"
    if type -t _mrg_rdh > /dev/null; then
        _mrg_rdh
    fi
    if [[ $TERM_PROGRAM != Apple_Terminal && ( $TERM == xterm* || $TERM == screen* ) ]]; then
        _precmd_title "$cmd"
    fi
    _powerline_set_prompt
}

preexec_install
