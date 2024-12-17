if [[ $BATS_LOADED != 1 ]]; then
  export BATS_LOADED=1
  export PATH="${BATS_TEST_DIRNAME}/libexec:$PATH"
fi

# Just so the terminal isn't an issue
FOCUS_TEST_bold="$(tput bold)"
FOCUS_TEST_nobold="$(tput sgr0)"
export FOCUS_TEST_bold FOCUS_TEST_nobold

fixtures() {
  FIXTURE_ROOT="$BATS_TEST_DIRNAME/fixtures/$1"
  # shellcheck disable=SC2034
  RELATIVE_FIXTURE_ROOT="${FIXTURE_ROOT#"$BATS_CWD"/}"
  if [[ $BATS_ROOT == "$BATS_CWD" ]]; then
    RELATIVE_BATS_ROOT=''
  else
    RELATIVE_BATS_ROOT=${BATS_ROOT#"$BATS_CWD"/}
  fi
  if [[ -n "$RELATIVE_BATS_ROOT" && "$RELATIVE_BATS_ROOT" != */ ]]; then
    RELATIVE_BATS_ROOT+=/
  fi
}

device_setup() {
  export PATH="$FIXTURE_ROOT/$1:$PATH"
}
