#!/usr/bin/env bash
#
# Using this:
#   test_android_focus_command.sh <string> <previous serial>
#
REPO_DIR="$( cd -P "$( dirname $0 )/../.." && pwd )"

# Set up the completion environment. Not really needed for "focus" but
# is needed to source the file below.
command -v brew > /dev/null 2>&1
if [ $? -eq 0 ]; then \
    source /usr/local/share/bash-completion/bash_completion
elif [ -f /usr/share/bash-completion/bash_completion ]; then \
    source /usr/share/bash-completion/bash_completion
else \
    # Wait, why is there a prefix here?
    source ${prefix}/etc/bash_completion
fi
source ${REPO_DIR}/home/.bashrc.d/20-android-focus.bash

ANDROID_SERIAL=$1
echo "[START serial=$ANDROID_SERIAL]"
focus $2
echo "[END serial=$ANDROID_SERIAL]"
