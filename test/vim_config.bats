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

@test "vim uses built-in filetypes and modern terminal colors" {
    refute grep -Eq 'vim-colors-solarized|gitignore\.vim|vim-fish|csapprox|genindent|vimproc|vim-reunions' \
        "$BATS_TEST_DIRNAME/../dot_vim/settings/plugins.vim"
    refute grep -q 'CSApprox_' "$BATS_TEST_DIRNAME/../dot_vimrc"
}

@test "vim plugins are installed after chezmoi applies the configuration" {
    local install_script="$BATS_TEST_DIRNAME/../run_onchange_after_install-vim-plugins.sh.tmpl"

    assert [ -f "$install_script" ]
    assert grep -q 'include "dot_vim/settings/plugins.vim" | sha256sum' "$install_script"
    assert grep -q "PlugInstall --sync" "$install_script"
}

@test "vim-startify links to the vim-plug updater" {
    assert grep -q 'let g:startify_custom_header = \[\]' \
        "$BATS_TEST_DIRNAME/../dot_vim/settings/plugins.vim"
    assert grep -q "'Update Vim plugins', 'PlugUpdate'" \
        "$BATS_TEST_DIRNAME/../dot_vim/settings/plugins.vim"
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
