"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NeoBundle configuration
"
" :Unite neobundle/upgrade
"
" For more help see the NeoBundle website:
" https://github.com/Shougo/neobundle.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has('vim_starting')
    set runtimepath+=~/.vim/bundle/neobundle.vim/
endif
call neobundle#begin(expand('~/.vim/bundle/'))

" Homeshick manages this update now.
NeoBundleFetch 'Shugo/neobundle.vim'


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" My bundles
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Gives me a nice status line
NeoBundle 'Lokaltog/powerline'

NeoBundle 'Lokaltog/vim-easymotion'

" Shows git status in the 'gutter'
NeoBundle 'airblade/vim-gitgutter'

" Solarized color scheme
NeoBundle 'altercation/vim-colors-solarized'

" This provides live-update webpage editing.
NeoBundleLazy 'Bogdanp/browser-connect.vim', {
    \ 'filetypes': ['html', 'xhtml'],
    \ }

" Searches for semantic C/C++ matches
NeoBundleLazy 'brookhong/cscope.vim', {
    \ 'filetypes': ['c', 'cpp'],
    \ }

" Provides a class outline for files in a separate window
NeoBundle 'majutsushi/tagbar'

" Gives better numbering depending on what mode you're in.
NeoBundle 'myusuf3/numbers.vim'

" Syntax highlighting today
NeoBundleLazy 'rdolgushin/gitignore.vim', {
    \ 'filename_patterns': '^\.gitignore$',
    \ }

" Syntax checking plugin
NeoBundle 'scrooloose/syntastic'

" Allows quick comment in many languages
NeoBundle 'tomtom/tcomment_vim'

" Git integration
NeoBundle 'tpope/vim-fugitive'

NeoBundleLazy 'tpope/vim-repeat', {
    \ 'mappings': '.',
    \ }

" Easily change quotings
NeoBundleLazy 'tpope/vim-surround', {
    \ }
"   \ 'mappings': [['nxo', 'cs', 'ds', 'yss'], ['v', 'S']],
NeoBundleLazy 'tpope/vim-unimpaired', {
    \ 'mappings': ['[', ']'],
    \ }

" Color scheme tweaks
NeoBundle 'godlygeek/csapprox'

" Generic indenting plugin that uses b:indent_block_start and
" b:indent_block_end
NeoBundle 'genindent.vim'

" Filetype editing
NeoBundle 'sheerun/vim-polyglot'

" Cryptol files
NeoBundleLazy 'victoredwardocallaghan/cryptol.vim', {
    \ 'filetypes': ['cryptol'],
    \ }

" Fish (shell) files
NeoBundleLazy 'dag/vim-fish', {
    \ 'filetypes': ['fish'],
    \ }

NeoBundleLazy 'sukima/xmledit', {
    \ 'filetypes': ['html', 'sgml', 'xml'],
    \ }
NeoBundleLazy 'vim-scripts/bash-support.vim', {
    \ 'filetypes': ['bash', 'sh'],
    \ }

" YouCompleteMe
if filereadable(expand('~/.at_google.vim'))
    " Google-only
    source ~/.at_google.vim
else
    NeoBundle 'Valloric/YouCompleteMe', {
        \ 'build' : {
        \     'unix': './install.py --clang-completer --gocode-completer',
        \     'mac': './install.py --clang-completer --gocode-completer',
        \ }}
endif

" Vimproc, asynchronous execution library
NeoBundleLazy 'Shougo/vimproc.vim', {
      \ 'build' : {
      \     'windows' : 'make -f make_mingw32.mak',
      \     'cygwin' : 'make -f make_cygwin.mak',
      \     'mac' : 'make -f make_mac.mak',
      \     'unix' : 'make -f make_unix.mak',
      \ }}
" Makes using vimproc easier
NeoBundle 'osyo-manga/vim-reunions'

" Snippets
NeoBundleLazy 'Shougo/neosnippet.vim', {
    \ 'depends' : ['Shougo/neosnippet-snippets', 'Shougo/context_filetype.vim'],
    \ 'insert' : 1,
    \ 'filetypes' : 'snippet',
    \ 'unite_sources' : [
    \    'neosnippet', 'neosnippet/user', 'neosnippet/runtime'],
    \ }
NeoBundle 'honza/vim-snippets'

" My syntax plugins and suff
NeoBundle 'kruton/vimstuff'

" Gradle syntax
NeoBundleLazy 'tfnico/vim-gradle', {
   \ 'filetypes': 'gradle'
   \ }

" Completion
NeoBundleLazy 'Shougo/unite.vim', {
    \ 'commands': [ { 'name': 'Unite',
    \                 'complete': 'customlist,unite#complete_source' },
    \               'UniteWithCursorWord', 'UniteWithInput' ],
    \ 'depends': ['Shougo/vimproc.vim'],
    \ }

" cscope
NeoBundle "simplyzhao/cscope_maps.vim"
NeoBundle "JCLiang/vim-cscope-utils"

" LaTeX automatic mode
NeoBundleLazy 'coot/atp_vim', {
    \ 'name': 'atp-vim',
    \ 'filetypes': 'tex',
    \ }

" Solarized colorscheme
NeoBundle 'altercation/vim-colors-solarized'

" File browser
NeoBundleLazy 'Shougo/vimfiler.vim', {
    \ 'depends' : 'Shougo/unite.vim',
    \ 'commands' : [
    \         { 'name' : 'VimFiler',
    \           'complete' : 'customlist,vimfiler#complete' },
    \         { 'name' : 'VimFilerTab',
    \           'complete' : 'customlist,vimfiler#complete' },
    \         { 'name' : 'VimFilerExplorer',
    \           'complete' : 'customlist,vimfiler#complete' },
    \         { 'name' : 'Edit',
    \           'complete' : 'customlist,vimfiler#complete' },
    \         { 'name' : 'Write',
    \           'complete' : 'customlist,vimfiler#complete' },
    \         'Read', 'Source'],
    \ 'mappings' : '<Plug>',
    \ 'explorer' : 1,
    \ }

" Sorting in visual mode; allows sorting lines based on a block.
NeoBundle 'navicore/vissort.vim', {
    \ 'commands' : [ 'Vissort' ]
    \ }

" This gives a fancy starting screen when Vim starts up
NeoBundle 'mhinz/vim-startify' "{{{
  let g:startify_change_to_vcs_root = 1
  let g:startify_show_sessions = 1
  let g:startify_session_delete_buffers = 1
  let g:startify_session_persistence = 1
  let g:startify_bookmarks = [ {'p': '~/.vim/settings/plugins.vim'} ]
  nnoremap <F1> :Startify<cr>
"}}}

""" Testing utilities

" Helps with running unit tests
NeoBundleLazy 'janko-m/vim-test', {
    \ 'depends': [ 'tpope/vim-dispatch' ],
    \ 'commands': [ 'TestNearest',
    \               'TestFile',
    \               'TestSuite',
    \               'TestLast',
    \               'TestVisit',
    \             ],
    \ } "{{{
  let test#strategy = "dispatch"
"}}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NeoBundle housekeeping - MUST BE AT END!
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call neobundle#end()
filetype plugin indent on

NeoBundleCheck
