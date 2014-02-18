"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NeoBundle configuration
"
" :Unite neobundle/upgrade
"
" For more help see the NeoBundle website:
" https://github.com/Shougo/neobundle.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set runtimepath+=~/.vim/bundle/neobundle.vim/
call neobundle#rc(expand('~/.vim/bundle/'))

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
NeoBundle 'Bogdanp/browser-connect.vim'

" Searches for semantic C/C++ matches
NeoBundle 'brookhong/cscope.vim'

" Provides a class outline for files in a separate window
NeoBundle 'majutsushi/tagbar'

" Gives better numbering depending on what mode you're in.
NeoBundle 'myusuf3/numbers.vim'

" Syntax highlighting today
NeoBundle 'rdolgushin/gitignore.vim'

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
NeoBundle 'sukima/xmledit'
NeoBundle 'vim-scripts/bash-support.vim'

" YouCompleteMe
NeoBundle 'Valloric/YouCompleteMe', {
    \ 'build' : {
    \     'unix': './install.sh --clang-completer',
    \     'mac': './install.sh --clang-completer',
    \   },
    \ }

" Vimproc, asynchronous execution library
NeoBundle 'Shougo/vimproc', {
      \ 'build' : {
      \     'windows' : 'make -f make_mingw32.mak',
      \     'cygwin' : 'make -f make_cygwin.mak',
      \     'mac' : 'make -f make_mac.mak',
      \     'unix' : 'make -f make_unix.mak',
      \    },
      \ }

" SnipMate
NeoBundle "MarcWeber/vim-addon-mw-utils"
NeoBundle "tomtom/tlib_vim"
NeoBundle "garbas/vim-snipmate"
NeoBundle "honza/vim-snippets"
NeoBundle 'scrooloose/snipmate-snippets'

" Color schemes
NeoBundle 'flazz/vim-colorschemes'

" My syntax plugins and suff
NeoBundle 'kruton/vimstuff'

" Completion
NeoBundle 'Shougo/unite.vim'
