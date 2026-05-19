#!/usr/bin/env bash

declare -gA _lazy_completion_loaders=()
declare -ga _lazy_bash_completion_files=(
    /etc/bash_completion
    /usr/share/bash-completion/bash_completion
    /usr/local/share/bash-completion/bash_completion
)

_lazy_completion_register() {
    local command="$1"
    local loader="$2"

    _lazy_completion_loaders["$command"]="$loader"
    complete -o bashdefault -o default -F _lazy_completion_load "$command"
}

_lazy_completion_load() {
    local command="${COMP_WORDS[0]}"
    local loader="${_lazy_completion_loaders[$command]}"

    complete -r "$command" 2> /dev/null || true

    if [[ -n $loader ]]; then
        eval "$loader"
        unset "_lazy_completion_loaders[$command]"
    fi

    return 124
}

_lazy_bash_completion_register() {
    complete -D -o bashdefault -o default -F _lazy_bash_completion_load
}

_lazy_bash_completion_load() {
    local file

    complete -r -D 2> /dev/null || true

    for file in "${_lazy_bash_completion_files[@]}"; do
        if [[ -f $file ]]; then
            # shellcheck disable=SC1090
            source "$file"
            break
        fi
    done

    return 124
}

