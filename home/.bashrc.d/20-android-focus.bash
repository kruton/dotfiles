#
# Bash script to focus on certain Android devices. Intended to be included
# into one's .bashrc
#
# Author: Kenny Root <kenny@the-b.org>
# Last change: Sep 9, 2014
#

focus() {
    local wasmsg
    if [[ -n ${ANDROID_SERIAL} ]]; then
        wasmsg=" (was ${ANDROID_SERIAL})"
    fi

    if [[ -n "$1" ]]; then
        ANDROID_SERIAL=$1
        echo "Focused on ${ANDROID_SERIAL}${wasmsg}"
    else
        unset ANDROID_SERIAL
        echo "Cleared device focus${wasmsg}"
    fi

    _focus_reset

    export ANDROID_SERIAL
}

_focus_match_device() {
    local device cur

    device="$1"
    cur="$2"

    if [[ ${device} == ${cur}* ]]; then
        return 0
    else
        return 1
    fi
}

_focus_reset() {
    # For tracking whether to display descriptions of devices.
    _focus__comment_last=1
    _focus__comment_pos=0
}
_focus_reset

_focus() {
    local cur device nocasematch serial description
    local -a devices descriptions

    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"

    # complete only if the user is typing the first word of the command
    if (( $COMP_CWORD == 1 )); then
        # See whether we need to toggle nocasematch
        shopt -q nocasematch; (( nocasematch = !$? ))

        # Either it's on or we need to set it
        (( nocasematch )) || shopt -s nocasematch

        while read -r serial description; do
            if [[ -n $serial && $serial != List ]] && _focus_match_device "$serial" "$cur"; then
                devices+=( "$serial" )
                descriptions+=( "$description" )
            fi
        done < <(adb devices -l)
        while read -r serial description; do
            if [[ -n $serial ]] && _focus_match_device "$serial" "$cur"; then
                devices+=( "$serial" )
                descriptions+=( "$description" )
            fi
        done < <(fastboot devices -l)

        # Either it was on or we need to unset it
        (( nocasematch )) || shopt -u nocasematch

        [[ $_focus__comment_pos -gt $COMP_POINT ]] && _focus__comment_pos=0

        if [[ $_focus__comment_last == 0 && $_focus__comment_pos == $COMP_POINT ]]; then
            local bold="$(tput bold)"
            local nobold="$(tput sgr0)"
            for i in "${!devices[@]}"; do
                echo -ne "\n$bold${devices[$i]}$nobold - ${descriptions[$i]}"
            done
            _focus__comment_last=1
            COMPREPLY=
        else
            COMPREPLY=( "${devices[@]}" )
            if (( ${#devices[@]} == 1 )); then
                _focus_reset
            else \
                _focus__comment_last=0
            fi
        fi
        _focus__comment_pos=$COMP_POINT
    fi
}
complete -F _focus focus

# Local variables:
# mode: shell-script
# sh-basic-offset: 4
# sh-indent-comment: t
# indent-tabs-mode: nil
# End:
# ex: ts=4 sw=4 et filetype=sh
