#!/usr/bin/env bats

load test_helper
fixtures focus

@test "no serial but still clears" {
  run test_android_focus_command.sh "" ""
  assert_success
  assert_output <<EOF
[START serial=]
Cleared device focus
[END serial=]
EOF
}

@test "no wanted focus clears previous serial" {
  run test_android_focus_command.sh "1234" ""
  assert_success
  assert_output <<EOF
[START serial=1234]
Cleared device focus (was 1234)
[END serial=]
EOF
}

@test "wanted focus with no previous focus" {
  run test_android_focus_command.sh "" "AABBCC"
  assert_success
  assert_output <<EOF
[START serial=]
Focused on AABBCC
[END serial=AABBCC]
EOF
}

@test "wanted focus with previous focus" {
  run test_android_focus_command.sh "DEADBEEF" "00112233"
  assert_success
  assert_output <<EOF
[START serial=DEADBEEF]
Focused on 00112233 (was DEADBEEF)
[END serial=00112233]
EOF
}

@test "no devices" {
  device_setup none
  run test_android_focus_completion.sh "focus " 7 1
  assert_success
  assert_output <<EOF
[START 0: last=1,pos=0]
[COMPLETIONS 0]
[END 0: last=0,pos=7]
EOF
}

@test "single ADB device" {
  device_setup single-adb
  run test_android_focus_completion.sh \
      "focus " 7 1 \
      "focus 23" 9 1 \
      "focus 12345678 " 15 2
  assert_success
  assert_output <<EOF
[START 0: last=1,pos=0]
[COMPLETIONS 0]
12345678
[END 0: last=1,pos=0]
[START 1: last=1,pos=0]
[COMPLETIONS 1]
[END 1: last=0,pos=9]
[START 2: last=0,pos=9]
[COMPLETIONS 2]
[END 2: last=1,pos=0]
EOF
}

@test "two ADB devices" {
  device_setup two-adb
  run test_android_focus_completion.sh \
      "focus 1" 8 1 \
      "focus 1" 8 1 \
      "focus 123456" 13 1 \
      "focus 12345678 " 15 2
  assert_success
  assert_output <<EOF
[START 0: last=1,pos=0]
[COMPLETIONS 0]
12345678
123458823
[END 0: last=0,pos=8]
[START 1: last=0,pos=8]

${FOCUS_TEST_bold}12345678${FOCUS_TEST_nobold} - device usb:2-1.3.3 product:aosp_kroot model:AOSP_on_Kroot device:kroot
${FOCUS_TEST_bold}123458823${FOCUS_TEST_nobold} - device usb:2-1.3.3 product:aosp_grouper model:AOSP_on_Grouper device:grouper[COMPLETIONS 1]
[END 1: last=1,pos=8]
[START 2: last=1,pos=8]
[COMPLETIONS 2]
12345678
[END 2: last=1,pos=0]
[START 3: last=1,pos=0]
[COMPLETIONS 3]
[END 3: last=1,pos=0]
EOF
}

@test "one ADB device and one fastboot device" {
    device_setup one-adb-one-fastboot
    run test_android_focus_completion.sh \
        "focus " 7 1 \
        "focus " 7 1 \
        "focus 12" 9 1 \
        "focus 23" 9 1 \
        "focus 12345678 " 15 2
    assert_success
    assert_output <<EOF
[START 0: last=1,pos=0]
[COMPLETIONS 0]
12345678
23456789
[END 0: last=0,pos=7]
[START 1: last=0,pos=7]

${FOCUS_TEST_bold}12345678${FOCUS_TEST_nobold} - device usb:2-1.3.3 product:aosp_kroot model:AOSP_on_Kroot device:kroot
${FOCUS_TEST_bold}23456789${FOCUS_TEST_nobold} - fastboot[COMPLETIONS 1]
[END 1: last=1,pos=7]
[START 2: last=1,pos=7]
[COMPLETIONS 2]
12345678
[END 2: last=1,pos=0]
[START 3: last=1,pos=0]
[COMPLETIONS 3]
23456789
[END 3: last=1,pos=0]
[START 4: last=1,pos=0]
[COMPLETIONS 4]
[END 4: last=1,pos=0]
EOF
}

@test "two fastboot devices" {
  device_setup two-fastboot
  run test_android_focus_completion.sh \
      "focus " 8 1 \
      "focus " 8 1 \
      "focus 23456" 12 1 \
      "focus 23456789 " 15 2
  assert_success
  assert_output <<EOF
[START 0: last=1,pos=0]
[COMPLETIONS 0]
12345678
23456789
[END 0: last=0,pos=8]
[START 1: last=0,pos=8]

${FOCUS_TEST_bold}12345678${FOCUS_TEST_nobold} - fastboot1
${FOCUS_TEST_bold}23456789${FOCUS_TEST_nobold} - fastboot2[COMPLETIONS 1]
[END 1: last=1,pos=8]
[START 2: last=1,pos=8]
[COMPLETIONS 2]
23456789
[END 2: last=1,pos=0]
[START 3: last=1,pos=0]
[COMPLETIONS 3]
[END 3: last=1,pos=0]
EOF
}

