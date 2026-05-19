#!/usr/bin/env bats

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    load test_helper.bash
}

@test "vim external dependencies use vim-plug and not neobundle" {
    refute grep -q 'neobundle' "$BATS_TEST_DIRNAME/../.chezmoiexternal.toml"
    assert grep -q '".vim/autoload/plug.vim"' "$BATS_TEST_DIRNAME/../.chezmoiexternal.toml"
}

@test "vim-plug plugin declarations are unique" {
    run bash -c "sed -n \"s/^[[:space:]]*Plug[[:space:]]*'\\([^']*\\)'.*/\\1/p\" \"$BATS_TEST_DIRNAME/../dot_vim/settings/plugins.vim\" | sort | uniq -d"

    assert_success
    refute_output
}

@test "vim backup config centralizes recovery files outside projects" {
    command -v vim > /dev/null || skip "vim is not installed"

    home="$BATS_TEST_TMPDIR/home"
    mkdir "$home"

    run env HOME="$home" vim -Nu NONE -n -es \
        -S "$BATS_TEST_DIRNAME/../dot_vim/settings/backup.vim" \
        -c 'redir => options' \
        -c 'silent set directory? backupdir? swapfile? backup? writebackup? undodir? undofile?' \
        -c 'redir END' \
        -c 'put =options' \
        -c '%print' \
        -c 'qa!'

    assert_success
    assert_output --partial "directory=~/.vim/state/swap//"
    assert_output --partial "backupdir=~/.vim/state/backup//"
    assert_output --partial "undodir=~/.vim/state/undo//"
    assert_output --partial "swapfile"
    assert_output --partial "backup"
    assert_output --partial "writebackup"
    assert_output --partial "undofile"

    assert [ -d "$home/.vim/state/swap" ]
    assert [ -d "$home/.vim/state/backup" ]
    assert [ -d "$home/.vim/state/undo" ]
}
