#!/usr/bin/env bats

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    load "$DIR/../home/.bashrc.d/98-dedupe-function"
}

@test "empty list dedupe" {
    run dedupe_path_list ""
    assert_output ""
}

@test "single entry dedupe" {
    run dedupe_path_list "/bin"
    assert_output "/bin"
}

@test "single repeated entry dedupe" {
    run dedupe_path_list "/bin:/bin:/bin"
    assert_output "/bin"
}

@test "list with no repeated entry dedupe" {
    run dedupe_path_list "/bin:/usr/bin:/usr/local/bin"
    assert_output "/bin:/usr/bin:/usr/local/bin"
}

@test "list with many repeated entries dedupe" {
    run dedupe_path_list "/bin:/usr/bin:/bin:/usr/bin:/usr/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/bin:/usr/bin"
    assert_output "/bin:/usr/bin:/usr/local/bin"
}
