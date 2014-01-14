#!/bin/bash

# By Glyph Lefkowitz
# Modified by Alex Wood

# xterm-title.sh -- This script uses the precmd and preexec facilities created
# in preexec.sh to change the title of the xterm (or screen) window to reflect
# the current command being run.

# Change the title of the xterm.
function _preexec_xterm_title () {
    local title="$1"
    echo -ne "\e]0;$title\007"
}

# Change the title of a screen
function _preexec_screen_title () {
    local title="$1"
    echo -ne "\ek$1\e\\"
}

function _abbreviate_path () {
    # Replace instances of $HOME in $PWD with ~.  `dirs -0` does it too, but slower.
    local working_dir="${PWD/#$HOME/~}"
    if [[ $working_dir != "~" ]]
    then
        #E.g. /usr/local/share becomes share/
        local working_dir="${PWD##/*/}/"
    fi

    echo $working_dir
}

# Don't bother changing the title for commands that take very little time.  
# Eliminates an annoying flicker on the title bar.
function _display_command () {
    local banned_commands=( 'ls' 'cd' 'bg' 'fg' 'pwd' 'pushd' 'popd' )
    for cmd in "${banned_commands[@]}"
    do
        if [[ "$1" == "$cmd" ]]
        then
            return 1
        fi
    done

    return 0
}

function _precmd_title () {
    local android_title=$(_android_title)
    # Strip off everything past the first period in the hostname.  hostname -s will
    # do this, but using the bash built-in is faster.
    _preexec_xterm_title "${android_title}${android_title+ }${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/~}"

    if [[ $TERM == screen* ]]
    then
        _preexec_screen_title `_abbreviate_path`
    fi
}

# Echos Android product spec if in an Android build environment.
function _android_title () {
    if [[ -n $TARGET_PRODUCT ]]; then
        # TOO SLOW!
        #local arch=$(gettargetarch)
        local product=$TARGET_PRODUCT
        local variant=$TARGET_BUILD_VARIANT
        local apps=$TARGET_BUILD_APPS
        if [ -z "$apps" ]; then
            echo "[${product}-${variant}]"
        else
            echo "[${apps} ${variant}]"
        fi
    fi
}

function _preexec_title () {
    # Give me the command name sans any arguments
    local cutit="$1"
    local cmdtitle=`echo "$cutit" | cut -d " " -f 1`

    if _display_command "$cmdtitle"
    then
        local android_title="$(_android_title)"
        _preexec_xterm_title "$1 ${android_title}${android_title+ }(${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/~})"
        if [[ $TERM == screen* ]]
        then
            # if the user invoked screen with a command (e.g. "screen links")
            # the value of $1 is exec which isn't very useful.
            if [[ "$cmdtitle" == "exec" ]]
            then
                local cmdtitle=`echo "$cutit" | cut -d " " -f 2`
            fi
            _preexec_screen_title "$cmdtitle"
        fi
    fi
}
