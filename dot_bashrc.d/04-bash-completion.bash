# -*- shell-script -*-

if [[ -n "$BASH_VERSION" && -z "$BASH_COMPLETION_COMPAT_DIR" ]]; then
    _lazy_bash_completion_register
fi
