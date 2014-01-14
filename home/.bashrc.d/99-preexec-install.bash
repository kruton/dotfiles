# This runs all the things that want to use preexec-like functionality

function preexec() {
    _mrg_ec
    if [[ $TERM == xterm* || $TERM == screen* ]]; then
        _preexec_title
    fi
}

function precmd() {
    local last_exit_code=$?
    _mrg_rdh
    if [[ $TERM == xterm* || $TERM == screen* ]]; then
        _precmd_title
    fi
    _powerline_prompt
}

preexec_install
