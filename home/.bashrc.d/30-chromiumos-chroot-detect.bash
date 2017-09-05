#!/usr/bin/env bash
#
# Try to detect ChromiumOS chroot environment.

if [[ $CROS_WORKON_SRCROOT == /mnt/host/source ]]; then
    export POWERLINE_NO_SHELL_PROMPT=true
fi

