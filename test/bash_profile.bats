#!/usr/bin/env bats

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    load test_helper.bash

    HOME="$BATS_TEST_TMPDIR/home"
    export HOME
    mkdir -p "$HOME/bin"
}

@test "bash_profile adds home bin before sourcing bashrc" {
    cat > "$HOME/.bashrc" <<'EOF'
printf '%s\n' "$PATH" > "$HOME/path-seen-by-bashrc"
EOF

    # Limit PATH only inside the shell under test. Bats needs /bin utilities
    # such as cat and rm on macOS for assertions and cleanup.
    run bash --noprofile --norc -c '
        export PATH=/usr/bin
        source "$1"
    ' bash "$BATS_TEST_DIRNAME/../dot_bash_profile"
    assert_success

    run cat "$HOME/path-seen-by-bashrc"
    assert_success
    assert_output "$HOME/bin:/usr/bin"
}

@test "bash_profile dedupes path after local profile hooks" {
    cat > "$HOME/.bashrc" <<EOF
source "$BATS_TEST_DIRNAME/../dot_bashrc.d/98-dedupe-function.bash"
EOF
    cat > "$HOME/.bash_profile.local" <<'EOF'
PATH="$HOME/bin:$PATH:/usr/bin"
EOF

    run bash --noprofile --norc -c '
        export PATH=/usr/bin
        source "$1"
        printf "%s\n" "$PATH"
    ' bash "$BATS_TEST_DIRNAME/../dot_bash_profile"
    assert_success
    assert_output "$HOME/bin:/usr/bin"
}
