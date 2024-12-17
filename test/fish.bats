#!/usr/bin/env bats

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    load test_helper.bash
}

@test "fish has no errors" {
    run fish -c "echo success"
    assert_output "success"
}
