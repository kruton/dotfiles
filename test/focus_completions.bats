#!/usr/bin/env bats

load test_helper
fixtures focus

@test "no devices" {
  device_setup none
  run test_android_focus.sh "focus " 7 1
  assert_success
  assert_output <<EOF
[START 0]
[COMPLETIONS 0]
[END 0]
EOF
}

@test "single ADB device" {
  device_setup single-adb
  run test_android_focus.sh \
      "focus " 7 1 \
      "focus " 7 1
  assert_success
  assert_output <<EOF
[START 0]
[COMPLETIONS 0]
12345678
[END 0]
[START 1]
[COMPLETIONS 1]
12345678
[END 1]
EOF
}

@test "two ADB device" {
  device_setup two-adb
  run test_android_focus.sh \
      "focus 1" 8 1 \
      "focus 1" 8 1 \
      "focus 123456" 13 1
  assert_success
  assert_output <<EOF
[START 0]
[COMPLETIONS 0]
12345678
123458823
[END 0]
[START 1]

${FOCUS_TEST_bold}12345678${FOCUS_TEST_nobold} - device usb:2-1.3.3 product:aosp_kroot model:AOSP_on_Kroot device:kroot
${FOCUS_TEST_bold}123458823${FOCUS_TEST_nobold} - device usb:2-1.3.3 product:aosp_grouper model:AOSP_on_Grouper device:grouper[COMPLETIONS 1]

[END 1]
[START 2]
[COMPLETIONS 2]
12345678
[END 2]
EOF
}

