# -*- shell-script -*-

if [[ -n "$BASH_VERSION" && -z "$BASH_COMPLETION_COMPAT_DIR" ]]; then
    for file in \
        /etc/bash_completion \
            /usr/share/bash-completion/bash_completion \
            /usr/local/share/bash-completion/bash_completion; do
        if [[ -f "$file" ]]; then
            # shellcheck disable=SC1090
            source "$file" && break
        fi
    done
fi
