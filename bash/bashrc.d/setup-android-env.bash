#!/bin/bash
# Android environment chooser script.
#
# Last updated 2012-12-10 by Kenny Root

# Android target selection routine. Make sure you end the ANDROID_DIR
# with a trailing slash.
if [ -z "${ANDROID_DIR}" ]; then
    echo 'Error: ANDROID_DIR not set. Please set in ~/.bashrc.local.pre'
elif [ "x${ANDROID_DIR##*/}" != "x" ]; then
    # add trailing slash
    ANDROID_DIR="${ANDROID_DIR}/"
fi

export ANDROID_DIR

clean_up() {
    if [ -f "$1" ]; then
        rm -f "$1"
    fi
}

if [ ! -z "${ANDROID_DIR}" -a -d "${ANDROID_DIR}" ]; then \
    declare -a targets
    cnt=0

    for dir in `find ${ANDROID_DIR} -maxdepth 1 '(' -type d -or -type l ')' -and '!' -name '.*' -print`; do \
        trimmed_dir=${dir#${ANDROID_DIR}}
        if [ "x${trimmed_dir}" != "x" ]; then \
            targets[$cnt]=${trimmed_dir}
            cnt=$((cnt+1))
        fi
    done

    target=""
    if [ ${cnt} -eq 1 ]; then \
        target=${targets[0]}
    else \
        dialog_cmd="dialog --output-fd 5 --menu Targets: 15 40 $cnt "
        for ((i = 0; i < ${#targets[@]}; i++)); do \
            dialog_cmd="${dialog_cmd} $i ${targets[$i]}"
        done
        tmp_file=$(tempfile)
        trap 'clean_up ${tmp_file}' EXIT SIGINT SIGQUIT SIGTERM
        tput smcup
        eval $dialog_cmd 5> ${tmp_file}
        ret=$?
        tput rmcup
        if [ $ret -eq 0 ]; then \
            clear
            read target_number < ${tmp_file}
            target=${targets[$target_number]}
        fi
    fi
    if [ "${target}x" != "x" ]; then \
        export TOP=${ANDROID_DIR}${target}
        export CCACHE_BASEDIR=${TOP}
        pushd ${TOP} > /dev/null 2>&1
        . ${TOP}/build/envsetup.sh
        popd > /dev/null 2>&1
    fi
else
    echo "Error: Invalid Android directory: ${ANDROID_DIR}"
    echo "       Will not setup Android development environment"
fi

trap - EXIT SIGINT SIGQUIT SIGTERM
clean_up ${tmp_file}
