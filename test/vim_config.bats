#!/usr/bin/env bats

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    load test_helper.bash
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

@test "neovim backup config centralizes recovery files in nvim state" {
    command -v nvim > /dev/null || skip "nvim is not installed"

    home="$BATS_TEST_TMPDIR/home"
    mkdir "$home"

    run env HOME="$home" nvim --headless -Nu NONE -n -es \
        -S "$BATS_TEST_DIRNAME/../dot_vim/settings/backup.vim" \
        -c 'redir => options' \
        -c 'silent set directory? backupdir? swapfile? backup? writebackup? undodir? undofile?' \
        -c 'redir END' \
        -c 'put =options' \
        -c '%print' \
        -c 'qa!'

    assert_success
    assert_output --partial "directory=~/.local/state/nvim/swap//"
    assert_output --partial "backupdir=~/.local/state/nvim/backup//"
    assert_output --partial "undodir=~/.local/state/nvim/undo//"
    assert_output --partial "swapfile"
    assert_output --partial "backup"
    assert_output --partial "writebackup"
    assert_output --partial "undofile"

    assert [ -d "$home/.local/state/nvim/swap" ]
    assert [ -d "$home/.local/state/nvim/backup" ]
    assert [ -d "$home/.local/state/nvim/undo" ]
}

@test "neovim loads shared config without errors" {
    command -v nvim > /dev/null || skip "nvim is not installed"

    local home="$BATS_TEST_TMPDIR/home"
    mkdir -p "$home"

    run env HOME="$home" nvim --headless \
        -u "$BATS_TEST_DIRNAME/../dot_config/nvim/init.lua" \
        -c 'qa!'

    assert_success
    refute_output
}

@test "neovim disables YouCompleteMe for MOO files" {
    command -v nvim > /dev/null || skip "nvim is not installed"

    local home="$BATS_TEST_TMPDIR/home"
    mkdir -p "$home"

    run env HOME="$home" nvim --headless -Nu NONE -n \
        -S "$BATS_TEST_DIRNAME/../dot_vim/settings/moo.vim" \
        -c 'echo get(g:ycm_filetype_blacklist, "moo", 0)' \
        -c 'qa!'

    assert_success
    assert_output "1"
}
