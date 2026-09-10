#!/usr/bin/env bash

#
# Bash script to focus on certain Android devices. Intended to be included
# into one's .bashrc
#
# Author: Kenny Root <kenny@the-b.org>
# Last change: Sep 9, 2014
#

focus() {
    if [[ "${1:-}" == "-s" || "${1:-}" == "--status" ]]; then
        if [[ -n ${ANDROID_SERIAL:-} ]]; then
            printf 'Currently focused on %s\n' "${ANDROID_SERIAL}"
        else
            printf 'No device focus set\n'
        fi
        return 0
    fi

    local wasmsg=""
    if [[ -n ${ANDROID_SERIAL:-} ]]; then
        wasmsg=" (was ${ANDROID_SERIAL})"
    fi

    if [[ -n "${1:-}" ]]; then
        export ANDROID_SERIAL="$1"
        printf 'Focused on %s%s\n' "${ANDROID_SERIAL}" "${wasmsg}"
    else
        unset ANDROID_SERIAL
        printf 'Cleared device focus%s\n' "${wasmsg}"
    fi

    _focus_reset
}

_focus_match_device() {
    local device="$1"
    local cur="$2"
    [[ $device == "$cur"* ]]
}

_focus_reset() {
    # For tracking whether to display descriptions of devices.
    _focus__comment_last=1
    _focus__comment_pos=0
}
_focus_reset

_focus() {
    local cur serial description
    local -a devices=() descriptions=()

    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Complete only if the user is typing the first argument
    if (( COMP_CWORD != 1 )); then
        _focus_reset
        return 0
    fi

    local restore_nocasematch=0
    if ! shopt -q nocasematch; then
        shopt -s nocasematch
        restore_nocasematch=1
    fi

    if command -v adb > /dev/null 2>&1; then
        while read -r serial description; do
            [[ -z $serial || $serial == List || $serial == \** ]] && continue
            if _focus_match_device "$serial" "$cur"; then
                devices+=( "$serial" )
                descriptions+=( "$description" )
            fi
        done < <(adb devices -l 2>/dev/null)
    fi

    if command -v fastboot > /dev/null 2>&1; then
        while read -r serial description; do
            [[ -z $serial || $serial == \** ]] && continue
            if _focus_match_device "$serial" "$cur"; then
                devices+=( "$serial" )
                descriptions+=( "$description" )
            fi
        done < <(fastboot devices -l 2>/dev/null)
    fi

    if (( restore_nocasematch )); then
        shopt -u nocasematch
    fi

    [[ $_focus__comment_pos -gt $COMP_POINT ]] && _focus__comment_pos=0

    if [[ $_focus__comment_last == 0 && $_focus__comment_pos == "$COMP_POINT" ]]; then
        local bold nobold
        bold="$(tput bold 2>/dev/null || true)"
        nobold="$(tput sgr0 2>/dev/null || true)"
        for i in "${!devices[@]}"; do
            printf '\n%s%s%s - %s' "$bold" "${devices[i]}" "$nobold" "${descriptions[i]}"
        done
        _focus__comment_last=1
        COMPREPLY=()
    else
        COMPREPLY=( "${devices[@]}" )
        if (( ${#devices[@]} == 1 )); then
            _focus_reset
        else
            _focus__comment_last=0
            _focus__comment_pos=$COMP_POINT
        fi
    fi
}
complete -F _focus focus
