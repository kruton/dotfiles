" Use moo-lsp-rs for LambdaMOO files through YouCompleteMe.
let s:moo_lsp_binary = expand('~/.local/bin/moo-lsp-rs' . (has('win32') ? '.exe' : ''))
let g:ycm_language_server = get(g:, 'ycm_language_server', []) + [
    \ {
    \   'name': 'moo-lsp-rs',
    \   'cmdline': [s:moo_lsp_binary],
    \   'filetypes': ['moo'],
    \   'project_root_files': ['.git'],
    \ },
    \ ]

augroup moo_ycm
  autocmd!
  autocmd FileType moo let b:ycm_enable_semantic_highlighting = 1
augroup END
