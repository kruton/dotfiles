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
    \ 'autoload': { 'filetypes': ['html'] }}

" Searches for semantic C/C++ matches
NeoBundleLazy 'brookhong/cscope.vim', {
    \ 'autoload': { 'filetypes': ['c', 'cpp'] }}

" Provides a class outline for files in a separate window
NeoBundle 'majutsushi/tagbar'

" Gives better numbering depending on what mode you're in.
NeoBundle 'myusuf3/numbers.vim'

" Syntax highlighting today
NeoBundleLazy 'rdolgushin/gitignore.vim', {
    \ 'autoload': { 'filename_patterns': ['^\.gitignore$'] }}

" Syntax checking plugin
NeoBundle 'scrooloose/syntastic'

" Allows quick comment in many languages
NeoBundle 'tomtom/tcomment_vim'

" Git integration
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'tpope/vim-git'

NeoBundle 'tpope/vim-repeat'

" Easily change quotings
NeoBundle 'tpope/vim-surround'
NeoBundle 'tpope/vim-unimpaired'
NeoBundle 'CSApprox'
NeoBundle 'genindent.vim'

" Filetype editing
NeoBundleLazy 'sukima/xmledit', {
    \ 'autoload': { 'filetypes': ['html', 'sgml', 'xml'] }}
NeoBundleLazy 'vim-scripts/bash-support.vim', {
    \ 'autoload': { 'filetypes': ['bash', 'sh'] }}

" YouCompleteMe
if filereadable(expand('~/.at_google.vim'))
    " Google-only
    source ~/.at_google.vim
else
    NeoBundle 'Valloric/YouCompleteMe', {
        \ 'build' : {
        \     'unix': './install.sh --clang-completer',
        \     'mac': './install.sh --clang-completer',
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

" SnipMate
NeoBundle 'MarcWeber/vim-addon-mw-utils'
NeoBundle 'tomtom/tlib_vim'
NeoBundle 'garbas/vim-snipmate'
NeoBundle 'honza/vim-snippets'
NeoBundle 'scrooloose/snipmate-snippets'

" Color schemes
NeoBundle 'flazz/vim-colorschemes'

" My syntax plugins and suff
NeoBundle 'kruton/vimstuff'

" Completion
NeoBundleLazy 'Shougo/unite.vim', {
    \ 'autoload': { 'commands': ['Unite', 'UniteWithBufferDir'] },
    \ 'depends': ['Shougo/vimproc.vim'] }

" Syntax for nginx config files
NeoBundleLazy 'yaroot/vim-nginx', {
    \ 'autoload': { 'filename_patterns': ['nginx'] }}

" LaTeX automatic mode
NeoBundleLazy 'coot/atp_vim', {
    \ 'name': 'atp-vim',
    \ 'autoload': { 'filetypes': ['tex'] }}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NeoBundle housekeeping - MUST BE AT END!
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call neobundle#end()
filetype plugin indent on

NeoBundleCheck
