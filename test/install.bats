#!/usr/bin/env bats

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    command -v chezmoi >/dev/null || skip "chezmoi is not installed"

    REPO="$BATS_TEST_DIRNAME/.."
    TEST_SOURCE="$BATS_TEST_TMPDIR/source"
    TEST_HOME="$BATS_TEST_TMPDIR/home"
    mkdir -p "$TEST_SOURCE/.chezmoidata" "$TEST_HOME"
    cp "$REPO/.chezmoidata/packages.yaml" "$TEST_SOURCE/.chezmoidata/"
    cp "$REPO/.chezmoidata/runtimes.yaml" "$TEST_SOURCE/.chezmoidata/"
    printf '[data]\ndevserver = false\n' > "$BATS_TEST_TMPDIR/chezmoi.toml"
}

chezmoi_test() {
    env HOME="$TEST_HOME" chezmoi \
        --config "$BATS_TEST_TMPDIR/chezmoi.toml" \
        --persistent-state "$BATS_TEST_TMPDIR/state.boltdb" \
        --cache "$BATS_TEST_TMPDIR/cache" \
        --source "$TEST_SOURCE" --destination "$TEST_HOME" "$@"
}

@test "shell and Git installation preserves Starship and converges after migration" {
    # Use real managed files and migration scripts, without downloading tools
    # or running package managers and editor plugin installers on the host.
    cp "$REPO/dot_bashrc" "$REPO/dot_bash_profile" \
        "$REPO/dot_bash_aliases" "$REPO/dot_gitconfig.tmpl" \
        "$REPO/.chezmoiremove" \
        "$REPO/run_once_after_migration.sh" "$TEST_SOURCE/"
    mkdir -p "$TEST_SOURCE/dot_bashrc.d" "$TEST_HOME/.bashrc.d"
    cp "$REPO/dot_bashrc.d/91-starship.bash" "$TEST_SOURCE/dot_bashrc.d/"
    local obsolete
    for obsolete in 49-homebrew-path.bash 49-macports-path.bash 49-pip-local-user.bash; do
        printf '# obsolete module\n' > "$TEST_HOME/.bashrc.d/$obsolete"
    done
    printf '# machine-local module\n' > "$TEST_HOME/.bashrc.d/50-local.bash"

    # Deletions should be visible for review before applying.
    run chezmoi_test diff --no-pager
    assert_success
    for obsolete in 49-homebrew-path.bash 49-macports-path.bash 49-pip-local-user.bash; do
        assert_output --partial "$obsolete"
    done

    run chezmoi_test apply
    assert_success
    for obsolete in 49-homebrew-path.bash 49-macports-path.bash 49-pip-local-user.bash; do
        [ ! -e "$TEST_HOME/.bashrc.d/$obsolete" ]
    done
    [ -f "$TEST_HOME/.bashrc.d/50-local.bash" ]
    cmp "$REPO/dot_bashrc.d/91-starship.bash" "$TEST_HOME/.bashrc.d/91-starship.bash"
    cmp "$REPO/dot_bashrc" "$TEST_HOME/.bashrc"
    cmp "$REPO/dot_bash_profile" "$TEST_HOME/.bash_profile"

    # Verify convergence immediately, before another apply can repair damage.
    run chezmoi_test diff --no-pager
    assert_success
    refute_output
    run chezmoi_test apply
    assert_success
    run chezmoi_test diff --no-pager
    assert_success
    refute_output

    # Recreated files remain removal targets; explicitly accept the conflict.
    touch "$TEST_HOME/.bashrc.d/49-homebrew-path.bash"
    run chezmoi_test apply --force
    assert_success
    [ ! -e "$TEST_HOME/.bashrc.d/49-homebrew-path.bash" ]

    printf '[core]\n autocrlf = false\n[merge]\n conflictstyle = merge\n' > "$TEST_HOME/.gitconfig.local"
    run git config --file "$TEST_HOME/.gitconfig" --includes --get core.autocrlf
    assert_success
    assert_output false
    run git config --file "$TEST_HOME/.gitconfig" --includes --get merge.conflictstyle
    assert_success
    assert_output merge
}

@test "apt installer renders for Debian and Ubuntu only" {
    local osid
    for osid in linux-debian linux-ubuntu; do
        run chezmoi_test --override-data "{\"osid\":\"$osid\"}" \
            execute-template --file "$REPO/run_onchange_debian_install-packages.sh.tmpl"
        assert_success
        assert_output --partial 'sudo apt-get install -y'
        assert_output --partial 'python3-pip'
        printf '%s\n' "$output" | bash -n
    done
    for osid in linux-fedora darwin linux-arch; do
        run chezmoi_test --override-data "{\"osid\":\"$osid\"}" \
            execute-template --file "$REPO/run_onchange_debian_install-packages.sh.tmpl"
        assert_success
        refute_output
    done
}

prepare_runtime_install() {
    mkdir -p "$TEST_SOURCE/dot_config/mise" "$TEST_HOME/.local/bin"
    cp "$REPO/dot_config/mise/config.toml.tmpl" "$TEST_SOURCE/dot_config/mise/"
    cp "$REPO/run_onchange_after_install-runtimes.sh.tmpl" "$REPO/.chezmoiremove" "$TEST_SOURCE/"
    export NVM_DIR="$TEST_HOME/.nvm"
    # Record installer calls without downloading runtimes. Also verify that
    # configuration exists before the after-script runs.
    cat > "$TEST_HOME/.local/bin/mise" <<'EOF'
#!/bin/sh
set -eu
test -f "$HOME/.config/mise/config.toml"
test "$1" = -C
test "$2" = "$HOME"
shift 2
printf '%s\n' "$*" >> "$HOME/mise-calls"
if [ "$1" = install ]; then
    shift
    for tool in "$@"; do
        name=${tool%@*}
        version=${tool#*@}
        grep -F "$name = \"$version\"" "$HOME/.config/mise/config.toml" >/dev/null
    done
fi
EOF
    chmod +x "$TEST_HOME/.local/bin/mise"
}

@test "runtime migration reuses nvm installs and removes legacy startup modules" {
    prepare_runtime_install
    mkdir -p "$NVM_DIR/versions/node" "$TEST_HOME/.rbenv/versions" "$TEST_HOME/.bashrc.d"
    touch "$NVM_DIR/versions/node/keep" "$TEST_HOME/.rbenv/versions/keep"
    local module
    for module in 60-nvm.bash 60-rbenv.bash 90-node.bash; do
        touch "$TEST_HOME/.bashrc.d/$module"
    done

    run chezmoi_test apply
    assert_success
    for module in 60-nvm.bash 60-rbenv.bash 90-node.bash; do
        [ ! -e "$TEST_HOME/.bashrc.d/$module" ]
    done
    [ -f "$NVM_DIR/versions/node/keep" ]
    [ -f "$TEST_HOME/.rbenv/versions/keep" ]
    run cat "$TEST_HOME/mise-calls"
    assert_success
    assert_line --index 0 'sync node --nvm'
    assert_line --index 1 --partial 'install node@'
    assert_equal "${#lines[@]}" 2
    cp "$TEST_HOME/mise-calls" "$BATS_TEST_TMPDIR/expected-calls"

    run chezmoi_test apply
    assert_success
    cmp "$BATS_TEST_TMPDIR/expected-calls" "$TEST_HOME/mise-calls"
    run chezmoi_test diff --no-pager
    assert_success
    refute_output
}

@test "fresh runtime installation needs no legacy runtime manager" {
    prepare_runtime_install
    run chezmoi_test apply
    assert_success
    run cat "$TEST_HOME/mise-calls"
    assert_success
    assert_line --index 0 --partial 'install node@'
    assert_equal "${#lines[@]}" 1
    run grep -F 'idiomatic_version_file_enable_tools = ["node", "ruby"]' "$TEST_HOME/.config/mise/config.toml"
    assert_success
}
