#!/usr/bin/env bats

load test_helper
fixtures focus

@test "no devices" {
  device_setup none
  run test_android_focus.sh "focus " 7 1
  assert_success ""
}
