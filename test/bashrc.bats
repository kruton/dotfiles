#!/usr/bin/env bats

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    load test_helper.bash

    TEST_HOME="$BATS_TEST_TMPDIR/home"
    mkdir -p "$TEST_HOME/.bashrc.d" "$TEST_HOME/bin"

    cp "$BATS_TEST_DIRNAME/../dot_bashrc" "$TEST_HOME/.bashrc"
    cp "$BATS_TEST_DIRNAME/../dot_bash_aliases" "$TEST_HOME/.bash_aliases"
    cp "$BATS_TEST_DIRNAME/../dot_bash_profile" "$TEST_HOME/.bash_profile"

    for f in "$BATS_TEST_DIRNAME/../dot_bashrc.d"/*.bash; do
        [[ -e "$f" ]] || continue
        target_name="$(basename "$f")"
        if [[ $target_name == symlink_* ]]; then
            target_name="${target_name#symlink_}"
            : > "$TEST_HOME/.bashrc.d/$target_name"
        else
            cp "$f" "$TEST_HOME/.bashrc.d/$target_name"
        fi
    done
}

@test "bashrc returns immediately in non-interactive subshell" {
    run bash --noprofile --norc -c "source '$TEST_HOME/.bashrc'"
    assert_success
    refute_output
}

@test "bashrc loads cleanly in interactive subshell" {
    run env -i \
        HOME="$TEST_HOME" \
        PATH="$TEST_HOME/bin:/usr/local/bin:/usr/bin:/bin" \
        TERM="xterm-256color" \
        USER="testuser" \
        RUNNING_PERF="yes" \
        MISE_YES="1" \
        bash --noprofile --norc -i -c 'source ~/.bashrc && [[ -n $HISTSIZE ]]'

    assert_success
}

@test "bashrc is idempotent when sourced repeatedly" {
    run env -i \
        HOME="$TEST_HOME" \
        PATH="$TEST_HOME/bin:/usr/local/bin:/usr/bin:/bin" \
        TERM="xterm-256color" \
        USER="testuser" \
        RUNNING_PERF="yes" \
        MISE_YES="1" \
        bash --noprofile --norc -i -c 'source ~/.bashrc && source ~/.bashrc && echo IDEMPOTENT_OK'

    assert_success
    assert_output "IDEMPOTENT_OK"
}

@test "chezmoi templates and configuration render without errors" {
    command -v chezmoi > /dev/null || skip "chezmoi is not installed"

    local dest="$BATS_TEST_TMPDIR/chezmoi-dest"
    mkdir -p "$dest"

    run chezmoi init --source "$BATS_TEST_DIRNAME/.." --destination "$dest"
    assert_success

    run chezmoi diff --source "$BATS_TEST_DIRNAME/.." --destination "$dest"
    assert_success
}
