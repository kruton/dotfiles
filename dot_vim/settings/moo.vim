" Use moo-lsp-rs for LambdaMOO files through YouCompleteMe in Vim.
" In Neovim, nvim-lambdamoo provides native LSP and VFS support.
if !has('nvim')
  let s:moo_lsp_binary = expand('~/.local/bin/moo-lsp-rs' . (has('win32') ? '.exe' : ''))
  let g:ycm_language_server = get(g:, 'ycm_language_server', []) + [
      \ {
      \   'name': 'moo-lsp-rs',
      \   'cmdline': [s:moo_lsp_binary],
      \   'filetypes': ['moo'],
      \   'project_root_files': ['.git'],
      \ },
      \ ]

  " YCM semantic-token property types are global rather than buffer-local.
  " Use standard highlight groups so the active colorscheme controls the palette.
  if has('textprop')
    function! s:ConfigureYcmSemanticHighlights() abort
      let l:semantic_highlights = {
        \ 'variable':   'Identifier',
        \ 'property':   'Type',
        \ 'function':   'Function',
        \ 'method':     'Special',
        \ 'keyword':    'Statement',
        \ 'comment':    'Comment',
        \ 'string':     'String',
        \ 'number':     'Number',
        \ 'operator':   'Operator',
        \ 'enumMember': 'Constant',
        \ }

      for [l:token_type, l:highlight_group] in items(l:semantic_highlights)
        let l:property_type = 'YCM_HL_' . l:token_type
        if empty(prop_type_get(l:property_type))
          call prop_type_add(l:property_type, {'highlight': l:highlight_group})
        else
          call prop_type_change(l:property_type, {'highlight': l:highlight_group})
        endif
      endfor
    endfunction

    " settings/*.vim is sourced before :syntax on and :colorscheme in vimrc.
    " Wait until VimEnter so all standard highlight groups are available.
    augroup ycm_semantic_highlights
      autocmd!
      autocmd VimEnter * call <SID>ConfigureYcmSemanticHighlights()
    augroup END

    if v:vim_did_enter
      call s:ConfigureYcmSemanticHighlights()
    endif
  endif

  augroup moo_ycm
    autocmd!
    autocmd FileType moo let b:ycm_enable_semantic_highlighting = 1
  augroup END
else
  let g:ycm_filetype_blacklist = get(g:, 'ycm_filetype_blacklist', {})
  let g:ycm_filetype_blacklist['moo'] = 1
endif

