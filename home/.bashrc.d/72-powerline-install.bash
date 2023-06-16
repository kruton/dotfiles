#!/bin/bash

# installs powerline if not installed

# To get around PEP 668
_PIP_INSTALL_ARGS=""

if [[ ! -x $HOME/.local/bin/powerline ]]; then \
    _PYTHON_BIN="$(command -v python3)"
    if [ $? -ne 0 ]; then \
        _PYTHON_BIN="$(command -v python)"
        if [[ $? -ne 0 ]]; then \
            unset $_PYTHON_BIN
        fi
    fi
    if [[ -x $_PYTHON_BIN ]]; then \
        if $_PYTHON_BIN -m pip install --help | grep -- --break-system-packages > /dev/null 2>&1; then \
            _PIP_INSTALL_ARGS="--break-system-packages"
        fi
        $_PYTHON_BIN -m pip install --user --editable="$HOME/.homesick/repos/powerline" "${_PIP_INSTALL_ARGS[@]}"
    fi
fi

unset _PIP_INSTALL_ARGS
unset _PYTHON_BIN
