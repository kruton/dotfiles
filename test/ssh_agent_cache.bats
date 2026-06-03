#!/usr/bin/env bats
# shellcheck disable=SC2329

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    load test_helper.bash

    export XDG_RUNTIME_DIR="$BATS_TEST_TMPDIR/runtime"
    mkdir -m 700 "$XDG_RUNTIME_DIR"
    load "$BATS_TEST_DIRNAME/../dot_bashrc.d/90-ssh-find-agent.bash"

    _test_agent_socket() {
        # shellcheck disable=SC2317
        [[ $1 == "$BATS_TEST_TMPDIR/agent.sock" ]]
    }

    _ssh_agent_socket_exists() {
        # shellcheck disable=SC2317
        [[ -e $1 ]]
    }
}

@test "cached ssh agent socket is used when cache is private and socket is live" {
    socket="$BATS_TEST_TMPDIR/agent.sock"
    touch "$socket"

    cache_dir="$XDG_RUNTIME_DIR/dotfiles"
    mkdir -m 700 "$cache_dir"
    printf '%s\n' "$socket" > "$cache_dir/ssh-auth-sock"
    chmod 600 "$cache_dir/ssh-auth-sock"

    _read_cached_ssh_agent_socket

    assert_equal "$SSH_AUTH_SOCK" "$socket"
}

@test "cached ssh agent socket is rejected when cache file is public" {
    socket="$BATS_TEST_TMPDIR/agent.sock"
    touch "$socket"

    cache_dir="$XDG_RUNTIME_DIR/dotfiles"
    mkdir -m 700 "$cache_dir"
    printf '%s\n' "$socket" > "$cache_dir/ssh-auth-sock"
    chmod 644 "$cache_dir/ssh-auth-sock"

    run _read_cached_ssh_agent_socket

    assert_failure
}

@test "writing ssh agent cache creates private runtime directory and private cache file" {
    SSH_AUTH_SOCK="$BATS_TEST_TMPDIR/agent.sock"
    export SSH_AUTH_SOCK
    touch "$SSH_AUTH_SOCK"

    _write_cached_ssh_agent_socket

    cache_file="$XDG_RUNTIME_DIR/dotfiles/ssh-auth-sock"
    run cat "$cache_file"
    assert_success
    assert_output "$SSH_AUTH_SOCK"

    cache_dir_mode="$(stat -c '%a' "$XDG_RUNTIME_DIR/dotfiles" 2> /dev/null || stat -f '%Lp' "$XDG_RUNTIME_DIR/dotfiles")"
    cache_file_mode="$(stat -c '%a' "$cache_file" 2> /dev/null || stat -f '%Lp' "$cache_file")"
    assert_equal "$cache_dir_mode" 700
    assert_equal "$cache_file_mode" 600
}

@test "ssh config IdentityAgent path expands home directory tokens" {
    HOME="$BATS_TEST_TMPDIR/home"

    # shellcheck disable=SC2088
    run _expand_ssh_identity_agent_path '~/.ssh/agent.sock'

    assert_success
    assert_output "$HOME/.ssh/agent.sock"
}

@test "ssh config IdentityAgent path expands SSH_AUTH_SOCK token" {
    SSH_AUTH_SOCK="$BATS_TEST_TMPDIR/live-agent.sock"
    export SSH_AUTH_SOCK

    run _expand_ssh_identity_agent_path 'SSH_AUTH_SOCK'

    assert_success
    assert_output "$SSH_AUTH_SOCK"
}

@test "gnome keyring fallback discovery populates keyring ssh socket candidates" {
    find() {
        # shellcheck disable=SC2317
        if [[ $* == "/tmp/keyring-* -maxdepth 1 -type s -name ssh" ]]; then
            printf '/tmp/keyring-test/ssh\n'
        fi
    }

    _find_all_legacy_tmp_gnome_keyring_agent_sockets

    assert_equal "$_GNOME_KEYRING_AGENT_SOCKETS" "/tmp/keyring-test/ssh"
}
