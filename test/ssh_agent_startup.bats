#!/usr/bin/env bats

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
}

@test "SSH agent module loads under errexit when discovery tools are absent" {
    local missing_tool
    for missing_tool in socat timeout ssh-add; do
        run bash --noprofile --norc -e -c '
            command() {
                if [[ $1 == -v && $2 == "$missing_tool" ]]; then
                    return 1
                fi
                builtin command "$@"
            }
            missing_tool=$2
            source "$1"
            printf "loaded\n"
        ' bash "$BATS_TEST_DIRNAME/../dot_bashrc.d/90-ssh-find-agent.bash" "$missing_tool"
        assert_success
        assert_output loaded
    done
}
