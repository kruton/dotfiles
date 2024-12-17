#!/usr/bin/env bats

load test_helper.bash

@test "fish has no errors" {
    run fish -c "echo success"
    assert_output "success"
}
