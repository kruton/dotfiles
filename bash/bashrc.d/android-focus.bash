#
# Bash script to focus on certain Android devices. Intended to be included
# into one's .bashrc
#
# Author: Kenny Root <kenny@the-b.org>
# Last change: Dec 10, 2012
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

    export ANDROID_SERIAL
}

_focus_match_device() {
    local device cur casematch

    device=$1
    cur=$2

    if [[ ${device} == ${cur}* ]]; then
        printf '%s\n' ${device}
    fi
}

_focus() {
    local cur device
    local -a devices

    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"

    # complete only if the user is typing the first word of the command
    if [ $COMP_CWORD -eq 1 ]; then
        local casematch=`shopt -p nocasematch`
        shopt -s nocasematch

        devices=( $(
            adb devices | while read -r serial junk; do
                if [[ -n ${serial} && ${serial} != List ]]; then
                    _focus_match_device ${serial} ${cur}
                fi
            done
            fastboot devices | while read -r serial junk; do
                if [[ -n ${serial} ]]; then
                    _focus_match_device ${serial} ${cur}
                fi
            done
        ) )

        eval ${casematch}
        COMPREPLY=( ${devices[@]:-} )
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
