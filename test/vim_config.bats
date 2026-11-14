#!/usr/bin/env bats

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    load test_helper.bash
    # Keep Neovim's startup log out of the working directory.
    export NVIM_LOG_FILE="$BATS_TEST_TMPDIR/nvim.log"
}

setup_plugin_installer() {
    command -v vim > /dev/null || skip "vim is not installed"
    home="$BATS_TEST_TMPDIR/home"
    mkdir -p "$home/.vim/autoload" "$home/.vim/settings" "$home/.vim/plugin"
    cp "$BATS_TEST_DIRNAME/../dot_vim/settings/plugins.vim" "$home/.vim/settings/plugins.vim"
    cat > "$home/.vim/autoload/plug.vim" <<'EOF'
function! plug#begin(...)
    let g:plugs = {}
    command! -bar -nargs=+ Plug call plug#register(<args>)
endfunction
function! plug#register(name, ...)
    let g:plugs[a:name] = {}
endfunction
function! plug#end()
    command! -nargs=* PlugUpdate call writefile([<q-args>], $HOME . '/updated')
    if !has('python3') && has_key(g:plugs, 'ycm-core/YouCompleteMe')
        throw 'YouCompleteMe requires Python 3'
    endif
    if !has('python') && !has('python3') && has_key(g:plugs, 'qytz/vim-cscope-utils')
        throw 'vim-cscope-utils requires Python'
    endif
endfunction
EOF
}

@test "vim plugin installer avoids interactive config and plugin startup" {
    setup_plugin_installer
    echo "throw 'interactive vimrc loaded'" > "$home/.vimrc"
    echo "throw 'installed plugin loaded'" > "$home/.vim/plugin/broken.vim"

    run env HOME="$home" sh "$BATS_TEST_DIRNAME/../run_onchange_after_install-vim-plugins.sh.tmpl"

    assert_success
    refute_output
    assert_equal "$(cat "$home/updated")" "--sync"
}

@test "vim plugin installer reports errors hidden by silent Ex mode" {
    setup_plugin_installer
    echo "throw 'plugin declaration failed'" >> "$home/.vim/settings/plugins.vim"

    run env HOME="$home" sh "$BATS_TEST_DIRNAME/../run_onchange_after_install-vim-plugins.sh.tmpl"

    assert_failure
    assert_output --partial "plugin declaration failed"
}

@test "vim plugin installer suppresses autocommands registered by file detection" {
    setup_plugin_installer
    # plug#end() sources file detection even with --noplugin. PlugUpdate also
    # reloads plugins, and creates unnamed windows that can break their hooks.
    cat >> "$home/.vim/settings/plugins.vim" <<'EOF'
autocmd BufEnter,BufWinEnter,VimLeave * throw 'interactive autocommand fired'
function! BatchUpdate()
    tabnew
    call writefile(['--sync'], $HOME . '/updated')
endfunction
command! -nargs=* PlugUpdate call BatchUpdate()
EOF

    run env HOME="$home" sh "$BATS_TEST_DIRNAME/../run_onchange_after_install-vim-plugins.sh.tmpl"

    assert_success
    refute_output
    assert_equal "$(cat "$home/updated")" "--sync"
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

@test "neovim inlay hint commands work without an external plugin" {
    command -v nvim > /dev/null || skip "nvim is not installed"
    local home="$BATS_TEST_TMPDIR/home"
    mkdir -p "$home"
    cat > "$BATS_TEST_TMPDIR/check-hints.lua" <<'EOF'
local hints = vim.lsp.inlay_hint
if not hints then return end
vim.cmd.InlayHintsEnable()
assert(hints.is_enabled({ bufnr = 0 }))
vim.cmd.InlayHintsToggle()
assert(not hints.is_enabled({ bufnr = 0 }))
vim.cmd.InlayHintsToggle()
assert(hints.is_enabled({ bufnr = 0 }))
vim.cmd.InlayHintsDisable()
assert(not hints.is_enabled({ bufnr = 0 }))

local supported = false
vim.lsp.get_client_by_id = function()
  return { supports_method = function(_, method)
    assert(method == 'textDocument/inlayHint')
    return supported
  end }
end
vim.api.nvim_exec_autocmds('LspAttach', { buffer = 0, data = { client_id = 1 } })
assert(not hints.is_enabled({ bufnr = 0 }))
supported = true
vim.api.nvim_exec_autocmds('LspAttach', { buffer = 0, data = { client_id = 1 } })
assert(hints.is_enabled({ bufnr = 0 }))
EOF

    run env HOME="$home" nvim --headless -i NONE \
        -u "$BATS_TEST_DIRNAME/../dot_config/nvim/init.lua" \
        -c "luafile $BATS_TEST_TMPDIR/check-hints.lua" -c 'qa!'

    assert_success
    refute_output
}
