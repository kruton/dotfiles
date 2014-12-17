#!/bin/bash
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
source /etc/bash_completion
source ${REPO_DIR}/home/.bashrc.d/20-android-focus.bash

read -a COMP_WORDS <<< "$1"
COMP_LINE="$1"
COMP_COUNT="$2"
COMP_CWORD="$3"
_focus
__print_completions
