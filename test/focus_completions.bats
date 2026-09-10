#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    load test_helper.bash
    fixtures focus

    # shellcheck source=/dev/null
    source "$BATS_TEST_DIRNAME/../dot_bashrc.d/20-android-focus.bash"
}

simulate_focus_completion() {
    local cmd_line="$1"
    local point="${2:-${#cmd_line}}"
    local cword="${3:-1}"

    read -r -a COMP_WORDS <<< "$cmd_line"
    COMP_LINE="$cmd_line"
    COMP_POINT="$point"
    COMP_CWORD="$cword"

    _focus
}

call_focus() {
    local out_file="$BATS_TEST_TMPDIR/focus_call.out"
    focus "$@" > "$out_file" 2>&1
    FOCUS_STATUS=$?
    FOCUS_OUTPUT="$(< "$out_file")"
}

# --- Command Tests ---

@test "focus clears focus and unsets ANDROID_SERIAL when no previous serial was set" {
    unset ANDROID_SERIAL
    call_focus
    assert_equal "$FOCUS_STATUS" 0
    assert_equal "$FOCUS_OUTPUT" "Cleared device focus"
    assert [ -z "${ANDROID_SERIAL+x}" ]
    assert [ -z "$(printenv ANDROID_SERIAL)" ]
}

@test "focus clears existing focus and unsets ANDROID_SERIAL in environment" {
    export ANDROID_SERIAL="1234"
    call_focus
    assert_equal "$FOCUS_STATUS" 0
    assert_equal "$FOCUS_OUTPUT" "Cleared device focus (was 1234)"
    assert [ -z "${ANDROID_SERIAL+x}" ]
    assert [ -z "$(printenv ANDROID_SERIAL)" ]
}

@test "focus sets and exports ANDROID_SERIAL when no previous serial was set" {
    unset ANDROID_SERIAL
    call_focus "AABBCC"
    assert_equal "$FOCUS_STATUS" 0
    assert_equal "$FOCUS_OUTPUT" "Focused on AABBCC"
    assert_equal "$ANDROID_SERIAL" "AABBCC"
    assert_equal "$(printenv ANDROID_SERIAL)" "AABBCC"
}

@test "focus updates and exports ANDROID_SERIAL when previous serial was set" {
    export ANDROID_SERIAL="DEADBEEF"
    call_focus "00112233"
    assert_equal "$FOCUS_STATUS" 0
    assert_equal "$FOCUS_OUTPUT" "Focused on 00112233 (was DEADBEEF)"
    assert_equal "$ANDROID_SERIAL" "00112233"
    assert_equal "$(printenv ANDROID_SERIAL)" "00112233"
}

@test "focus -s reports currently focused serial without modifying environment" {
    export ANDROID_SERIAL="PIXEL8"
    call_focus -s
    assert_equal "$FOCUS_STATUS" 0
    assert_equal "$FOCUS_OUTPUT" "Currently focused on PIXEL8"
    assert_equal "$ANDROID_SERIAL" "PIXEL8"
    assert_equal "$(printenv ANDROID_SERIAL)" "PIXEL8"
}

@test "focus --status reports when no focus is set without modifying environment" {
    unset ANDROID_SERIAL
    call_focus --status
    assert_equal "$FOCUS_STATUS" 0
    assert_equal "$FOCUS_OUTPUT" "No device focus set"
    assert [ -z "${ANDROID_SERIAL+x}" ]
    assert [ -z "$(printenv ANDROID_SERIAL)" ]
}

# --- Completion Tests ---

@test "completion does not modify ANDROID_SERIAL in environment" {
    export ANDROID_SERIAL="PRESERVED_SERIAL"
    device_setup two-adb
    simulate_focus_completion "focus "
    assert_equal "$ANDROID_SERIAL" "PRESERVED_SERIAL"
    assert_equal "$(printenv ANDROID_SERIAL)" "PRESERVED_SERIAL"
}

@test "completion with no devices returns empty COMPREPLY" {
    device_setup none
    simulate_focus_completion "focus "
    assert_equal "${#COMPREPLY[@]}" 0
}

@test "completion with single ADB device completes serial" {
    device_setup single-adb
    simulate_focus_completion "focus "
    assert_equal "${COMPREPLY[*]}" "12345678"
}

@test "completion filters multiple ADB devices by prefix" {
    device_setup two-adb
    simulate_focus_completion "focus 123456"
    assert_equal "${COMPREPLY[*]}" "12345678"

    simulate_focus_completion "focus 123458"
    assert_equal "${COMPREPLY[*]}" "123458823"
}

@test "completion lists all candidate devices when prefix matches multiple" {
    device_setup two-adb
    simulate_focus_completion "focus 12345"
    assert_equal "${#COMPREPLY[@]}" 2
    assert_equal "${COMPREPLY[0]}" "12345678"
    assert_equal "${COMPREPLY[1]}" "123458823"
}

@test "completion combines both ADB and fastboot devices" {
    device_setup one-adb-one-fastboot
    simulate_focus_completion "focus "
    assert_equal "${#COMPREPLY[@]}" 2
    assert_equal "${COMPREPLY[0]}" "12345678"
    assert_equal "${COMPREPLY[1]}" "23456789"
}

@test "completion works with only fastboot devices" {
    device_setup two-fastboot
    simulate_focus_completion "focus 2"
    assert_equal "${COMPREPLY[*]}" "23456789"
}

@test "repeated tab at same position displays device descriptions" {
    device_setup two-adb
    # First tab: populates completions
    simulate_focus_completion "focus "
    assert_equal "${#COMPREPLY[@]}" 2

    # Second tab at same cursor position: prints formatted descriptions
    run simulate_focus_completion "focus "
    assert_success
    assert_output --partial "12345678"
    assert_output --partial "AOSP_on_Kroot"
    assert_output --partial "123458823"
    assert_output --partial "AOSP_on_Grouper"
}

@test "completion ignores adb daemon startup banners" {
    local mock_bin="$BATS_TEST_TMPDIR/mock_bin"
    mkdir -p "$mock_bin"
    cat > "$mock_bin/adb" <<'EOF'
#!/bin/sh
echo "* daemon not running; starting now at tcp:5037"
echo "* daemon started successfully"
echo "List of devices attached"
printf 'DEVICE999\tdevice product:pixel model:Pixel device:pixel\n'
EOF
    chmod +x "$mock_bin/adb"
    PATH="$mock_bin:$PATH"

    simulate_focus_completion "focus "
    assert_equal "${COMPREPLY[*]}" "DEVICE999"
}

@test "completion handles missing adb and fastboot commands gracefully" {
    # shellcheck disable=SC2016
    run bash -c '
        source "'"$BATS_TEST_DIRNAME"'/../dot_bashrc.d/20-android-focus.bash"
        PATH="/nonexistent"
        COMP_WORDS=(focus "")
        COMP_LINE="focus "
        COMP_POINT=6
        COMP_CWORD=1
        _focus
        echo "${#COMPREPLY[@]}"
    '
    assert_success
    assert_output "0"
}

@test "completion does not complete for arguments beyond the first" {
    device_setup single-adb
    simulate_focus_completion "focus 12345678 extra" 20 2
    assert_equal "${#COMPREPLY[@]}" 0
}
