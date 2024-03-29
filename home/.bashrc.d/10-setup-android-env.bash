#!/usr/bin/env bash
#
# Android environment chooser script.
#
# Last updated 2014-02-07 by Kenny Root

# Android target selection routine. Make sure you end the ANDROID_DIR
# with a trailing slash.
if [[ -n ${ANDROID_DIR##*/} ]]; then
    # add trailing slash
    ANDROID_DIR="${ANDROID_DIR}/"
fi

export ANDROID_DIR

clean_up() {
    if [[ -f "$1" ]]; then
        rm -f "$1"
    fi
}

get_term_size_with_max() {
    local width height
    local max_height max_width

    max_height="$1"
    max_width="$2"

    read -r height width < <(stty size)

    echo $((height>max_height?max_height:height)) $((width>max_width?max_width:width))
}

switch_android_tree() {
    local -a targets
    local trimmed_dir target ret tmp_file
    local dir

    if [[ -n $ANDROID_DIR && -d $ANDROID_DIR ]]; then
        while IFS= read -r -d $'\0' dir; do
            trimmed_dir="${dir#$ANDROID_DIR/}"
            if [[ -n ${trimmed_dir} ]]; then
                targets+=("$trimmed_dir")
            fi
        done < <(shopt -s nullglob; for f in $ANDROID_DIR/*; do printf "%s\0" "$f"; done)

        target=""
        if command -v fzf > /dev/null; then
            target=$(fzf-tmux +m -0 -1 --read0 --layout=reverse < <(printf "%s\0" "${targets[@]}"))
        else
            if (( ${#targets[@]} == 1 )); then
                target="${targets[0]}"
            elif (( ${#targets[@]} > 0 )); then
                local dialog_cmd
                local tmp_file

                readarray -t sorted < <(printf '%s\0' "${targets[@]}" | sort -z | xargs -0n1)
                dialog_cmd="dialog --output-fd 5 --menu Targets: $(get_term_size_with_max $((${#sorted[@]}+7)) 40) ${#sorted[@]} "
                for (( i = 0; i < ${#sorted[@]}; i++ )); do
                    dialog_cmd="${dialog_cmd} $i ${sorted[$i]}"
                done
                tmp_file="$(mktemp)"
                trap 'clean_up "${tmp_file}"' EXIT SIGINT SIGQUIT SIGTERM
                tput smcup
                eval "$dialog_cmd" 5> "$tmp_file"
                (( ret = $? ))
                tput rmcup
                if (( ret == 0 )); then
                    clear
                    read -r target_number < "$tmp_file"
                    target="${sorted[$target_number]}"
                fi
            fi
        fi
        if [[ -n ${target} ]]; then
            export TOP="${ANDROID_DIR}${target}"
            export CCACHE_BASEDIR="${TOP}"
            export CDPATH="${CDPATH}:${ANDROID_DIR}"
            pushd "${TOP}" > /dev/null 2>&1

            if [[ -f ${TOP}/build/envsetup.sh ]]; then
                # shellcheck source=/dev/null
                . "${TOP}/build/envsetup.sh"
            elif [[ -f ${TOP}/trusty/vendor/google/aosp/scripts/envsetup.sh ]]; then
                # shellcheck source=/dev/null
                . "${TOP}/trusty/vendor/google/aosp/scripts/envsetup.sh"
            fi

            popd > /dev/null 2>&1
        fi
    fi

    trap - EXIT SIGINT SIGQUIT SIGTERM
    clean_up "${tmp_file}"
}

if [[ -z $RUNNING_PERF ]]; then
    switch_android_tree
fi
