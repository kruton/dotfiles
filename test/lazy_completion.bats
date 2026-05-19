#!/usr/bin/env bats

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    load test_helper.bash
    load "$BATS_TEST_DIRNAME/../dot_bashrc.d/03-lazy-completion.bash"
}

@test "lazy command completion installs real completion and asks bash to retry" {
    lazydemo() {
        printf '%s\n' \
            'complete -F _lazydemo_complete lazydemo' \
            '_lazydemo_complete() { COMPREPLY=(loaded); }'
    }

    _lazy_completion_register lazydemo "eval \"\$(lazydemo)\""

    COMP_WORDS=(lazydemo "")
    COMP_CWORD=1

    set +e
    _lazy_completion_load
    status=$?
    set -e

    assert_equal "$status" 124

    run complete -p lazydemo
    assert_success
    assert_output 'complete -F _lazydemo_complete lazydemo'
}

@test "lazy default bash completion sources configured completion file and asks bash to retry" {
    completion_file="$BATS_TEST_TMPDIR/bash_completion"
    cat > "$completion_file" <<'EOF'
_fake_default_complete() { COMPREPLY=(default-loaded); }
complete -F _fake_default_complete fakecmd
EOF

    _lazy_bash_completion_files=("$completion_file")
    _lazy_bash_completion_register

    run complete -p -D
    assert_success
    assert_output 'complete -o bashdefault -o default -F _lazy_bash_completion_load -D'

    COMP_WORDS=(fakecmd "")
    COMP_CWORD=1

    set +e
    _lazy_bash_completion_load
    status=$?
    set -e

    assert_equal "$status" 124

    run complete -p fakecmd
    assert_success
    assert_output 'complete -F _fake_default_complete fakecmd'
}
