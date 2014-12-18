#!/usr/bin/env bash
#
# Using this:
#   test_android_focus.sh <string> <cursor pos> <word pos> [<string> <cursor pos> <word pos> ...]
#
REPO_DIR="$( cd -P "$( dirname $0 )/../.." && pwd )"
FIXTURES_DIR="${REPO_DIR}/test/fixtures/"

__print_completions() {
    for ((i=0;i<${#COMPREPLY[*]};i++))
    do
       echo ${COMPREPLY[i]}
    done
}

assert_fixture() {
  local cmd
  cmd="$(type -p $1)"
  if [ "${cmd#${FIXTURES_DIR}}" = "${cmd}" ]; then
    echo $PATH
    echo "$cmd is not a fixture"
    exit 0
  fi
}
assert_fixture adb
assert_fixture fastboot

# Set up the completion environment
command -v brew > /dev/null 2>&1
if [ $? -eq 0 ]; then
    source /usr/local/share/bash-completion/bash_completion
else
    source ${prefix}/etc/bash_completion
fi
source ${REPO_DIR}/home/.bashrc.d/20-android-focus.bash

if (( ($# % 3) != 0 )); then
  echo "Expected multiples of 3 arguments but $# found."
  exit 0
fi

loop=0
while (( $# > 0 )); do
  read -a COMP_WORDS <<< "$1"
  COMP_LINE="$1"
  COMP_COUNT="$2"
  COMP_CWORD="$3"
  shift 3

  echo "[START $loop]"
  _focus
  echo "[COMPLETIONS $loop]"
  __print_completions
  echo "[END $loop]"
  loop=$((loop+1))
done
