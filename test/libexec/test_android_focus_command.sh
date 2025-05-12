#!/usr/bin/env bash
#
# Using this:
#   test_android_focus_command.sh <string> <previous serial>
#
REPO_DIR="$( cd -P "$( dirname "$0" )/../.." && pwd )"

# Set up the completion environment. Not really needed for "focus" but
# is needed to source the file below.
if command -v brew > /dev/null 2>&1; then \
    # shellcheck source=/dev/null
    source /usr/local/share/bash-completion/bash_completion
elif [ -f /usr/share/bash-completion/bash_completion ]; then \
    # shellcheck source=/dev/null
    source /usr/share/bash-completion/bash_completion
else \
    # Wait, why is there a prefix here?
    # shellcheck source=/dev/null
    source ${prefix}/etc/bash_completion
fi
# shellcheck source=/dev/null
source "${REPO_DIR}/dot_bashrc.d/20-android-focus.bash"

ANDROID_SERIAL=$1
echo "[START serial=$ANDROID_SERIAL]"
focus "$2"
echo "[END serial=$ANDROID_SERIAL]"
