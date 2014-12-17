if [[ $BATS_LOADED != 1 ]]; then
  export BATS_LOADED=1
  export PATH="${BATS_TEST_DIRNAME}/libexec:$PATH"
fi

# Just so the terminal isn't an issue
FOCUS_TEST_bold="$(tput bold)"
FOCUS_TEST_nobold="$(tput sgr0)"

fixtures() {
  FIXTURE_ROOT="${BATS_TEST_DIRNAME}/fixtures/$1"
  RELATIVE_FIXTURE_ROOT="$(bats_trim_filename "$FIXTURE_ROOT")"
}

device_setup() {
  export PATH="$FIXTURE_ROOT/$1:$PATH"
}

flunk() {
  { if [ "$#" -eq 0 ]; then cat -
    else echo "$@"
    fi
  } >&2
  return 1
}

assert_success() {
  if [ "$status" -ne 0 ]; then
    flunk "command failed with exit status $status"
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

assert_equal() {
  if [ "$1" != "$2" ]; then
    { echo "expected: \"$1\""
      echo "actual:   \"$2\""
    } | flunk
  fi
}

assert_output() {
  local expected
  if [ $# -eq 0 ]; then expected="$(cat -)"
  else expected="$1"
  fi
  assert_equal "$expected" "$output"
}

assert_line() {
  if [ "$1" -ge 0 ] 2>/dev/null; then
    assert_equal "$2" "${lines[$1]}"
  else
    local line
    for line in "${lines[@]}"; do
      if [ "$line" = "$1" ]; then return 0; fi
    done
    flunk "expected line \`$1'"
  fi
}

setup() {
  export TMP="${BATS_TEST_DIRNAME}/tmp"
}

teardown() {
  #[ -d "$TMP" ] && rm -f "$TMP"/*
  echo
}
