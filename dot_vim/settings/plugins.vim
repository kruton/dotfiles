"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" My bundles
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

call plug#begin('~/.vim/plugged')

" renovate: datasource=git-refs depName=easymotion/vim-easymotion packageName=https://github.com/easymotion/vim-easymotion.git currentValue=master
Plug 'easymotion/vim-easymotion', { 'commit': 'b3cfab2a6302b3b39f53d9fd2cd997e1127d7878' }

" Shows git status in the 'gutter'
" renovate: datasource=git-refs depName=airblade/vim-gitgutter packageName=https://github.com/airblade/vim-gitgutter.git currentValue=main
Plug 'airblade/vim-gitgutter', { 'commit': '90b75207bd9b55d8ac4af15f72b4e935462014d0' }

" This provides live-update webpage editing.
" renovate: datasource=git-refs depName=Bogdanp/browser-connect.vim packageName=https://github.com/Bogdanp/browser-connect.vim.git currentValue=master
Plug 'Bogdanp/browser-connect.vim', { 'commit': '1b2038f646b8b765ce2cdae4242a66e7876e2278',
    \ 'for': ['html', 'xhtml'],
    \ }

" Provides a class outline for files in a separate window
" renovate: datasource=git-refs depName=preservim/tagbar packageName=https://github.com/preservim/tagbar.git currentValue=master
Plug 'preservim/tagbar', { 'commit': '07cb8247487208124978daff8e13624667635457' }

" Gives better numbering depending on what mode you're in.
" renovate: datasource=git-refs depName=myusuf3/numbers.vim packageName=https://github.com/myusuf3/numbers.vim.git currentValue=master
Plug 'myusuf3/numbers.vim', { 'commit': '9657aed1d9eeff7e9c0ac2a97db60f1e4e47fe4d' }

" Syntax checking plugin
" renovate: datasource=git-refs depName=vim-syntastic/syntastic packageName=https://github.com/vim-syntastic/syntastic.git currentValue=master
Plug 'vim-syntastic/syntastic', { 'commit': '8d5e37c29cf5952fbf300b9230bffe424c61a488' } "{{{
  let g:syntastic_java_javac_config_file_enabled = 1
"}}}

" Allows quick comment in many languages
" renovate: datasource=git-refs depName=tomtom/tcomment_vim packageName=https://github.com/tomtom/tcomment_vim.git currentValue=master
Plug 'tomtom/tcomment_vim', { 'commit': '48ab639a461d9b8344f7fee06cb69b4374863b13' }

" Git integration
" renovate: datasource=git-refs depName=tpope/vim-fugitive packageName=https://github.com/tpope/vim-fugitive.git currentValue=master
Plug 'tpope/vim-fugitive', { 'commit': '3b753cf8c6a4dcde6edee8827d464ba9b8c4a6f0' }

" renovate: datasource=git-refs depName=tpope/vim-repeat packageName=https://github.com/tpope/vim-repeat.git currentValue=master
Plug 'tpope/vim-repeat', { 'commit': '65846025c15494983dafe5e3b46c8f88ab2e9635',
    \ }
"   \ 'mappings': '.',

" Easily change quotings
" renovate: datasource=git-refs depName=tpope/vim-surround packageName=https://github.com/tpope/vim-surround.git currentValue=master
Plug 'tpope/vim-surround', { 'commit': '3d188ed2113431cf8dac77be61b842acb64433d9',
    \ }
"   \ 'mappings': [['nxo', 'cs', 'ds', 'yss'], ['v', 'S']],
" renovate: datasource=git-refs depName=tpope/vim-unimpaired packageName=https://github.com/tpope/vim-unimpaired.git currentValue=master
Plug 'tpope/vim-unimpaired', { 'commit': 'db65482581a28e4ccf355be297f1864a4e66985c',
    \ }
"   \ 'mappings': ['[', ']'],

" Filetype editing
" renovate: datasource=git-refs depName=sheerun/vim-polyglot packageName=https://github.com/sheerun/vim-polyglot.git currentValue=master
Plug 'sheerun/vim-polyglot', { 'commit': 'f061eddb7cdcc614c8406847b2bfb53099832a4e' }

" Cryptol files
" renovate: datasource=git-refs depName=victoredwardocallaghan/cryptol.vim packageName=https://github.com/victoredwardocallaghan/cryptol.vim.git currentValue=master
Plug 'victoredwardocallaghan/cryptol.vim', { 'commit': '15040e77c8256c9d7a8824fd95804836121ed46a',
    \ 'for': ['cryptol'],
    \ }

" renovate: datasource=git-refs depName=sukima/xmledit packageName=https://github.com/sukima/xmledit.git currentValue=master
Plug 'sukima/xmledit', { 'commit': '6db863497f956ece4b0795fe19cb16d6c57f6543',
    \ 'for': ['html', 'sgml', 'xml'],
    \ }
" renovate: datasource=git-refs depName=vim-scripts/bash-support.vim packageName=https://github.com/vim-scripts/bash-support.vim.git currentValue=master
Plug 'vim-scripts/bash-support.vim', { 'commit': '309d6fe45859f2d30d0e8fe8016ca69f03b9f7d6',
    \ 'for': ['bash', 'sh'],
    \ }

" YouCompleteMe
if filereadable(expand('~/.at_google.vim'))
    " Google-only
    source ~/.at_google.vim
elseif !has('nvim') || has('python3')
    function! BuildYCM(info)
      " info is a dictionary with 3 fields
      " - name:   name of the plugin
      " - status: 'installed', 'updated', or 'unchanged'
      " - force:  set on PlugInstall! or PlugUpdate!
      if a:info.status == 'installed' || a:info.status == 'updated' || a:info.force
        let l:python_version = py3eval(
            \ '"{}.{}".format(*__import__("sys").version_info[:2])')
        let l:python = py3eval('__import__("sys").prefix') .
            \ (has('win32') ? '/python.exe' : '/bin/python' . l:python_version)
        if !executable(l:python)
          throw 'No Python interpreter matching Vim was found at ' . l:python
        endif

        execute '!' . shellescape(l:python) . ' install.py'
        if v:shell_error
          throw 'YouCompleteMe build failed with ' . l:python
        endif
      endif
    endfunction

    " renovate: datasource=git-refs depName=ycm-core/YouCompleteMe packageName=https://github.com/ycm-core/YouCompleteMe.git currentValue=master
    Plug 'ycm-core/YouCompleteMe', { 'commit': 'd4c91430b70a21ce471c8572400b647d313995b4', 'do': function('BuildYCM') }
endif

" coverage report for Python
" renovate: datasource=git-refs depName=alfredodeza/coveragepy.vim packageName=https://github.com/alfredodeza/coveragepy.vim.git currentValue=master
Plug 'alfredodeza/coveragepy.vim', { 'commit': 'afcef301b723048c25250d2d539b9473a8e4f747',
      \ 'for': ['python'],
      \ }

" Snippets
" renovate: datasource=git-refs depName=Shougo/neosnippet.vim packageName=https://github.com/Shougo/neosnippet.vim.git currentValue=master
Plug 'Shougo/neosnippet.vim', { 'commit': 'efb2a615df2e6df9364087686dacca223fcfa16a',
    \ 'insert' : 1,
    \ 'for' : 'snippet',
    \ 'unite_sources' : [
    \    'neosnippet', 'neosnippet/user', 'neosnippet/runtime'],
    \ }
  " renovate: datasource=git-refs depName=Shougo/neosnippet-snippets packageName=https://github.com/Shougo/neosnippet-snippets.git currentValue=master
  Plug 'Shougo/neosnippet-snippets', { 'commit': '725c989f18e9c134cddd63a7c6b15bed5c244657' }
  " renovate: datasource=git-refs depName=Shougo/context_filetype.vim packageName=https://github.com/Shougo/context_filetype.vim.git currentValue=master
  Plug 'Shougo/context_filetype.vim', { 'commit': 'ffb1ec4b2b3b34d77dd1a1b3610f2533eb69506c' }

" renovate: datasource=git-refs depName=honza/vim-snippets packageName=https://github.com/honza/vim-snippets.git currentValue=master
Plug 'honza/vim-snippets', { 'commit': 'ededcf7581962ee616cadab360d5966f3307f11a' }

" My syntax plugins and suff
" renovate: datasource=git-refs depName=kruton/vimstuff packageName=https://github.com/kruton/vimstuff.git currentValue=master
Plug 'kruton/vimstuff', { 'commit': 'f3778e7efc662b2ad475fa3faf77fea8712f1d4a' }

" Gradle syntax
" renovate: datasource=git-refs depName=tfnico/vim-gradle packageName=https://github.com/tfnico/vim-gradle.git currentValue=master
Plug 'tfnico/vim-gradle', { 'commit': '508629fa2a3be1b2052e4e553593f60d12dfc090',
   \ 'for': 'gradle'
   \ }

" Completion
" renovate: datasource=git-refs depName=Shougo/unite.vim packageName=https://github.com/Shougo/unite.vim.git currentValue=master
Plug 'Shougo/unite.vim', { 'commit': '0ccb3f7988d61a9a86525374be97360bd20db6bc',
    \ 'on': [ 'Unite',
    \         'UniteWithCursorWord', 'UniteWithInput' ]
    \ }

" cscope
" renovate: datasource=git-refs depName=simplyzhao/cscope_maps.vim packageName=https://github.com/simplyzhao/cscope_maps.vim.git currentValue=master
Plug 'simplyzhao/cscope_maps.vim', { 'commit': '4b11997b3794f51dbe69c7e2ee24e863dadcbd13' }
" renovate: datasource=git-refs depName=qytz/vim-cscope-utils packageName=https://github.com/qytz/vim-cscope-utils.git currentValue=master
Plug 'qytz/vim-cscope-utils', { 'commit': '8657d06675e9e0f80853da4d51e5789cc0908232' }

" LaTeX automatic mode
" renovate: datasource=git-refs depName=coot/atp_vim packageName=https://github.com/coot/atp_vim.git currentValue=master
Plug 'coot/atp_vim', { 'commit': 'cf8a0d73aad7dd84e8b010c34fec90a005b33408',
    \ 'name': 'atp-vim',
    \ 'for': 'tex',
    \ }

" File browser
" renovate: datasource=git-refs depName=Shougo/vimfiler.vim packageName=https://github.com/Shougo/vimfiler.vim.git currentValue=master
Plug 'Shougo/vimfiler.vim', { 'commit': '69d5bc6070d5b3ff4e73719d970bae50a71d2c67',
    \ 'on' : [
    \         'VimFiler',
    \         'VimFilerTab',
    \         'VimFilerExplorer',
    \         'Edit',
    \         'Write',
    \         'Read', 'Source'],
    \ }
"   \ 'mappings' : '<Plug>',

" Sorting in visual mode; allows sorting lines based on a block.
" renovate: datasource=git-refs depName=navicore/vissort.vim packageName=https://github.com/navicore/vissort.vim.git currentValue=master
Plug 'navicore/vissort.vim', { 'commit': 'd5ea31590e21d23894ce91847481a4f2310eef10',
    \ 'on' : [ 'Vissort' ]
    \ }

" This gives a fancy starting screen when Vim starts up
" renovate: datasource=git-refs depName=mhinz/vim-startify packageName=https://github.com/mhinz/vim-startify.git currentValue=master
Plug 'mhinz/vim-startify', { 'commit': '4e089dffdad46f3f5593f34362d530e8fe823dcf' } "{{{
  let g:startify_change_to_vcs_root = 1
  let g:startify_show_sessions = 1
  let g:startify_session_delete_buffers = 1
  let g:startify_session_persistence = 1
  let g:startify_custom_header = []
  let g:startify_bookmarks = [ {'p': '~/.vim/settings/plugins.vim'} ]
  let g:startify_commands = [
      \ {'u': ['Apply pinned Vim plugins', 'PlugUpdate']},
      \ ]
  nnoremap <F1> :Startify<cr>
"}}}

" renovate: datasource=git-refs depName=google/vim-maktaba packageName=https://github.com/google/vim-maktaba.git currentValue=master
Plug 'google/vim-maktaba', { 'commit': 'c9fd222c7ea3bde0952d2b879085e368ea75837b' }
" renovate: datasource=git-refs depName=bazelbuild/vim-bazel packageName=https://github.com/bazelbuild/vim-bazel.git currentValue=master
Plug 'bazelbuild/vim-bazel', { 'commit': '31b0d5e4f51da1aeb56d65bf505a744e6de405de' }

""" Testing utilities

" Helps with running unit tests
" renovate: datasource=git-refs depName=vim-test/vim-test packageName=https://github.com/vim-test/vim-test.git currentValue=master
Plug 'vim-test/vim-test', { 'commit': 'b2166d3934889747ef903ebc7b5079acf8e20c47',
    \ 'on': [ 'TestNearest',
    \         'TestFile',
    \         'TestSuite',
    \         'TestLast',
    \         'TestVisit',
    \       ],
    \ } "{{{
  let test#strategy = "dispatch"
"}}}
  " renovate: datasource=git-refs depName=tpope/vim-dispatch packageName=https://github.com/tpope/vim-dispatch.git currentValue=master
  Plug 'tpope/vim-dispatch', { 'commit': 'a2ff28abdb2d89725192db5b8562977d392a4d3f' }

" Erlang
" renovate: datasource=git-refs depName=vim-erlang/vim-erlang-runtime packageName=https://github.com/vim-erlang/vim-erlang-runtime.git currentValue=master
Plug 'vim-erlang/vim-erlang-runtime', { 'commit': '976b10b74c75d1297bef5b2a0e56ff2f75343ee8',
   \ 'for': 'erl'
   \ }
" renovate: datasource=git-refs depName=vim-erlang/vim-erlang-compiler packageName=https://github.com/vim-erlang/vim-erlang-compiler.git currentValue=master
Plug 'vim-erlang/vim-erlang-compiler', { 'commit': 'b334e956026f61c0bf289ffdf37ce9b2aefe01e1',
   \ 'for': 'erl'
   \ }
" renovate: datasource=git-refs depName=vim-erlang/vim-erlang-omnicomplete packageName=https://github.com/vim-erlang/vim-erlang-omnicomplete.git currentValue=master
Plug 'vim-erlang/vim-erlang-omnicomplete', { 'commit': '7337df845b90b51f24087716564789c70ae03dc3',
   \ 'for': 'erl'
   \ }
" renovate: datasource=git-refs depName=vim-erlang/vim-erlang-tags packageName=https://github.com/vim-erlang/vim-erlang-tags.git currentValue=master
Plug 'vim-erlang/vim-erlang-tags', { 'commit': '16b8a1266060ab538a6d0f8494ab6e754d69ba1e',
   \ 'for': 'erl'
   \ }

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plug housekeeping - MUST BE AT END!
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#end()
