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
        "$REPO/run_onchange_old_bashrcd.sh" \
        "$REPO/run_once_after_migration.sh" "$TEST_SOURCE/"
    mkdir -p "$TEST_SOURCE/dot_bashrc.d" "$TEST_HOME/.bashrc.d"
    cp "$REPO/dot_bashrc.d/91-starship.bash" "$TEST_SOURCE/dot_bashrc.d/"
    touch "$TEST_HOME/.bashrc.d/49-homebrew-path.bash"

    run chezmoi_test apply
    assert_success
    [ ! -e "$TEST_HOME/.bashrc.d/49-homebrew-path.bash" ]
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
