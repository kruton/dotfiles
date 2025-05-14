"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" My bundles
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

call plug#begin('~/.vim/plugged')

Plug 'Lokaltog/vim-easymotion'

" Shows git status in the 'gutter'
Plug 'airblade/vim-gitgutter'

" Solarized color scheme
Plug 'altercation/vim-colors-solarized'

" This provides live-update webpage editing.
Plug 'Bogdanp/browser-connect.vim', {
    \ 'for': ['html', 'xhtml'],
    \ }

" Provides a class outline for files in a separate window
Plug 'majutsushi/tagbar'

" Gives better numbering depending on what mode you're in.
Plug 'myusuf3/numbers.vim'

" Syntax highlighting today
Plug 'rdolgushin/gitignore.vim', {
    \ 'filename_patterns': '^\.gitignore$',
    \ }

" Syntax checking plugin
Plug 'scrooloose/syntastic' "{{{
  let g:syntastic_java_javac_config_file_enabled = 1
"}}}

" Allows quick comment in many languages
Plug 'tomtom/tcomment_vim'

" Git integration
Plug 'tpope/vim-fugitive'

Plug 'tpope/vim-repeat', {
    \ }
"   \ 'mappings': '.',

" Easily change quotings
Plug 'tpope/vim-surround', {
    \ }
"   \ 'mappings': [['nxo', 'cs', 'ds', 'yss'], ['v', 'S']],
Plug 'tpope/vim-unimpaired', {
    \ }
"   \ 'mappings': ['[', ']'],

" Color scheme tweaks
Plug 'godlygeek/csapprox'

" Generic indenting plugin that uses b:indent_block_start and
" b:indent_block_end
Plug 'vim-scripts/genindent.vim'

" Filetype editing
Plug 'sheerun/vim-polyglot'

" Cryptol files
Plug 'victoredwardocallaghan/cryptol.vim', {
    \ 'for': ['cryptol'],
    \ }

" Fish (shell) files
Plug 'dag/vim-fish', {
    \ 'for': ['fish'],
    \ }

Plug 'sukima/xmledit', {
    \ 'for': ['html', 'sgml', 'xml'],
    \ }
Plug 'vim-scripts/bash-support.vim', {
    \ 'for': ['bash', 'sh'],
    \ }

" YouCompleteMe
if filereadable(expand('~/.at_google.vim'))
    " Google-only
    source ~/.at_google.vim
else
    function! BuildYCM(info)
      " info is a dictionary with 3 fields
      " - name:   name of the plugin
      " - status: 'installed', 'updated', or 'unchanged'
      " - force:  set on PlugInstall! or PlugUpdate!
      if a:info.status == 'installed' || a:info.force
        !./install.py
      endif
    endfunction

    Plug 'Valloric/YouCompleteMe', { 'do': function('BuildYCM') }
endif

" coverage report for Python
Plug 'alfredodeza/coveragepy.vim', {
      \ 'for': ['python'],
      \ }

" Vimproc, asynchronous execution library
Plug 'Shougo/vimproc.vim', {'do' : 'make'}

" Makes using vimproc easier
Plug 'osyo-manga/vim-reunions'

" Snippets
Plug 'Shougo/neosnippet.vim', {
    \ 'insert' : 1,
    \ 'for' : 'snippet',
    \ 'unite_sources' : [
    \    'neosnippet', 'neosnippet/user', 'neosnippet/runtime'],
    \ }
  Plug 'Shougo/neosnippet-snippets'
  Plug 'Shougo/context_filetype.vim'

Plug 'honza/vim-snippets'

" My syntax plugins and suff
Plug 'kruton/vimstuff'

" Gradle syntax
Plug 'tfnico/vim-gradle', {
   \ 'for': 'gradle'
   \ }

" Completion
Plug 'Shougo/unite.vim', {
    \ 'on': [ 'Unite',
    \         'UniteWithCursorWord', 'UniteWithInput' ]
    \ }
  Plug 'Shougo/vimproc.vim'

" cscope
Plug 'simplyzhao/cscope_maps.vim'
Plug 'qytz/vim-cscope-utils'

" LaTeX automatic mode
Plug 'coot/atp_vim', {
    \ 'name': 'atp-vim',
    \ 'for': 'tex',
    \ }

" Solarized colorscheme
Plug 'altercation/vim-colors-solarized'

" File browser
Plug 'Shougo/vimfiler.vim', {
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
Plug 'navicore/vissort.vim', {
    \ 'on' : [ 'Vissort' ]
    \ }

" This gives a fancy starting screen when Vim starts up
Plug 'mhinz/vim-startify' "{{{
  let g:startify_change_to_vcs_root = 1
  let g:startify_show_sessions = 1
  let g:startify_session_delete_buffers = 1
  let g:startify_session_persistence = 1
  let g:startify_bookmarks = [ {'p': '~/.vim/settings/plugins.vim'} ]
  nnoremap <F1> :Startify<cr>
"}}}

Plug 'google/vim-maktaba'
Plug 'bazelbuild/vim-bazel'

""" Testing utilities

" Helps with running unit tests
Plug 'janko-m/vim-test', {
    \ 'on': [ 'TestNearest',
    \         'TestFile',
    \         'TestSuite',
    \         'TestLast',
    \         'TestVisit',
    \       ],
    \ } "{{{
  let test#strategy = "dispatch"
"}}}
  Plug 'tpope/vim-dispatch'

" Erlang
Plug 'vim-erlang/vim-erlang-runtime', {
   \ 'for': 'erl'
   \ }
Plug 'vim-erlang/vim-erlang-compiler', {
   \ 'for': 'erl'
   \ }
Plug 'vim-erlang/vim-erlang-omnicomplete', {
   \ 'for': 'erl'
   \ }
Plug 'vim-erlang/vim-erlang-tags', {
   \ 'for': 'erl'
   \ }

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plug housekeeping - MUST BE AT END!
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#end()
