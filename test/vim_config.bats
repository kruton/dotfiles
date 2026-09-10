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

@test "YouCompleteMe builds against Vim's embedded Python" {
    refute grep -q '!\./install.py' "$BATS_TEST_DIRNAME/../dot_vim/settings/plugins.vim"
    assert grep -q "py3eval('__import__(\"sys\").prefix')" \
        "$BATS_TEST_DIRNAME/../dot_vim/settings/plugins.vim"
    assert grep -q "'/bin/python' . l:python_version" \
        "$BATS_TEST_DIRNAME/../dot_vim/settings/plugins.vim"
}

@test "vim uses built-in filetypes and modern terminal colors" {
    refute grep -Eq 'vim-colors-solarized|gitignore\.vim|vim-fish|csapprox|genindent|vimproc|vim-reunions' \
        "$BATS_TEST_DIRNAME/../dot_vim/settings/plugins.vim"
    refute grep -q 'CSApprox_' "$BATS_TEST_DIRNAME/../dot_vimrc"
}

@test "LambdaMOO files use moo-lsp-rs through YouCompleteMe" {
    assert grep -q 'depName=kruton/moo-lsp-rs' "$BATS_TEST_DIRNAME/../.chezmoiexternal.toml"
    # shellcheck disable=SC2016
    assert grep -q 'moo-lsp-rs.*releases/download/{{ \$mooLspVersion }}' \
        "$BATS_TEST_DIRNAME/../.chezmoiexternal.toml"
    assert grep -q 'setfiletype moo' "$BATS_TEST_DIRNAME/../dot_vim/ftdetect/moo.vim"
    assert grep -q "'cmdline': \[s:moo_lsp_binary\]" \
        "$BATS_TEST_DIRNAME/../dot_vim/settings/moo.vim"
    assert grep -q "'filetypes': \['moo'\]" "$BATS_TEST_DIRNAME/../dot_vim/settings/moo.vim"
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

@test "neovim configuration bridges to vimrc" {
    local nvim_init="$BATS_TEST_DIRNAME/../dot_config/nvim/init.vim"

    assert [ -f "$nvim_init" ]
    assert grep -q "set runtimepath^=~/.vim runtimepath+=~/.vim/after" "$nvim_init"
    assert grep -q "source ~/.vimrc" "$nvim_init"
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

    run nvim --headless \
        -u "$BATS_TEST_DIRNAME/../dot_config/nvim/init.vim" \
        -c 'qa!'

    assert_success
    refute_output
}

@test "neovim manages kanagawa.nvim via chezmoiexternal" {
    assert grep -q 'depName=rebelot/kanagawa.nvim' "$BATS_TEST_DIRNAME/../.chezmoiexternal.toml"
    assert grep -q '".local/share/nvim/site/pack/plugins/start/kanagawa.nvim"' \
        "$BATS_TEST_DIRNAME/../.chezmoiexternal.toml"
}

@test "neovim manages plenary.nvim via chezmoiexternal" {
    assert grep -q 'depName=nvim-lua/plenary.nvim' "$BATS_TEST_DIRNAME/../.chezmoiexternal.toml"
    assert grep -q '".local/share/nvim/site/pack/plugins/start/plenary.nvim"' \
        "$BATS_TEST_DIRNAME/../.chezmoiexternal.toml"
}

@test "neovim manages inlay-hints.nvim via chezmoiexternal" {
    assert grep -q 'depName=MysticalDevil/inlay-hints.nvim' "$BATS_TEST_DIRNAME/../.chezmoiexternal.toml"
    assert grep -q '".local/share/nvim/site/pack/plugins/start/inlay-hints.nvim"' \
        "$BATS_TEST_DIRNAME/../.chezmoiexternal.toml"
}

@test "neovim configures inlay-hints" {
    local nvim_init="$BATS_TEST_DIRNAME/../dot_config/nvim/init.vim"

    assert [ -f "$nvim_init" ]
    assert grep -q 'require, "inlay-hints"' "$nvim_init"
    assert grep -q 'inlay_hints.setup()' "$nvim_init"
}

@test "neovim configures nvim-lambdamoo when repository is present" {
    local nvim_init="$BATS_TEST_DIRNAME/../dot_config/nvim/init.vim"

    assert [ -f "$nvim_init" ]
    assert grep -q "nvim-lambdamoo" "$nvim_init"
    assert grep -q 'lambdamoo.setup' "$nvim_init"
    assert grep -q 'authority = "codepoint"' "$nvim_init"
    assert grep -q 'endpoint = "https://codepoint.the-b.org/dav/"' "$nvim_init"
}

@test "neovim disables YouCompleteMe for MOO files" {
    command -v nvim > /dev/null || skip "nvim is not installed"

    run nvim --headless \
        -u "$BATS_TEST_DIRNAME/../dot_config/nvim/init.vim" \
        -c 'echo get(g:ycm_filetype_blacklist, "moo", 0)' \
        -c 'qa!'

    assert_success
    assert_output "1"
}
