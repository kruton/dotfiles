#!/usr/bin/env bash
#
# Using this:
#   test_android_focus_completion.sh <string> <cursor pos> <word pos> [<string> <cursor pos> <word pos> ...]
#
REPO_DIR="$( cd -P "$( dirname "$0" )/../.." && pwd )"
FIXTURES_DIR="${REPO_DIR}/test/fixtures/"

__print_completions() {
    for ((i=0;i<${#COMPREPLY[*]};i++))
    do
       echo "${COMPREPLY[i]}"
    done
}

assert_fixture() {
  local cmd
  cmd="$(type -p "$1")"
  if [ "${cmd#${FIXTURES_DIR}}" = "${cmd}" ]; then
    echo "$PATH"
    echo "$cmd is not a fixture"
    exit 0
  fi
}
assert_fixture adb
assert_fixture fastboot

# Set up the completion environment
if command -v brew > /dev/null 2>&1; then \
    # shellcheck source=/dv/null
    source /usr/local/share/bash-completion/bash_completion
elif [ -f /usr/share/bash-completion/bash_completion ]; then \
    # shellcheck source=/dv/null
    source /usr/share/bash-completion/bash_completion
else \
    # Wait, why is there a prefix here?
    # shellcheck source=/dv/null
    source "${prefix}/etc/bash_completion"
fi
# shellcheck source=/dv/null
source "${REPO_DIR}/dot_bashrc.d/20-android-focus.bash"

if (( ($# % 3) != 0 )); then
  echo "Expected multiples of 3 arguments but $# found."
  exit 0
fi

loop=0
while (( $# > 0 )); do
  read -r -a COMP_WORDS <<< "$1"
  COMP_LINE="$1"
  COMP_POINT="$2"
  COMP_CWORD="$3"
  shift 3

  echo "[START $loop: last=$_focus__comment_last,pos=$_focus__comment_pos]"
  _focus
  echo "[COMPLETIONS $loop]"
  __print_completions
  echo "[END $loop: last=$_focus__comment_last,pos=$_focus__comment_pos]"
  loop=$((loop+1))
done
