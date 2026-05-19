#!/usr/bin/env bats

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    load test_helper.bash

    HOME="$BATS_TEST_TMPDIR/home"
    export HOME
    mkdir -p "$HOME/bin"
}

@test "bash_profile adds home bin before sourcing bashrc" {
    cat > "$HOME/.bashrc" <<'EOF'
printf '%s\n' "$PATH" > "$HOME/path-seen-by-bashrc"
EOF

    PATH="/usr/bin"
    export PATH

    # shellcheck source=/dev/null
    source "$BATS_TEST_DIRNAME/../dot_bash_profile"

    run cat "$HOME/path-seen-by-bashrc"
    assert_success
    assert_output "$HOME/bin:/usr/bin"
}

@test "bash_profile dedupes path after local profile hooks" {
    cat > "$HOME/.bashrc" <<'EOF'
dedupe_path_list() {
    local _raw_list="${1#*:}"
    local _deduped_list="${1%%:*}"
    local _next_entry

    while [[ -n $_raw_list ]]; do
        if [[ $_raw_list =~ : ]]; then
            _next_entry="${_raw_list%%:*}"
            _raw_list="${_raw_list#*:}"
        else
            _next_entry="$_raw_list"
            _raw_list=""
        fi

        case ":${_deduped_list}:" in
            *:${_next_entry}:*) ;;
            *) _deduped_list="${_deduped_list}:${_next_entry}" ;;
        esac
    done

    echo "${_deduped_list}"
}
EOF
    cat > "$HOME/.bash_profile.local" <<'EOF'
PATH="$HOME/bin:$PATH:/usr/bin"
EOF

    PATH="/usr/bin"
    export PATH

    # shellcheck source=/dev/null
    source "$BATS_TEST_DIRNAME/../dot_bash_profile"

    assert_equal "$PATH" "$HOME/bin:/usr/bin"
}
