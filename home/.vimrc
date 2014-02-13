" Kenny Root's vimrc
" http://github.com/kruton/dotfiles
"

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible
filetype off " workaround vundle ftdetect bug

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vundle configuration
"
" :BundleInstall! upgrades bundles
"
" For more help see the vundle website:
" https://github.com/gmarik/vundle#readme
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set runtimepath+=~/.vim/bundle/neobundle.vim/
call neobundle#rc(expand('~/.vim/bundle/'))

" Homeshick manages this update now.
NeoBundleFetch 'Shugo/neobundle.vim'


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" My vundles
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'Lokaltog/powerline'
NeoBundle 'Lokaltog/vim-easymotion'
NeoBundle 'airblade/vim-gitgutter'
NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'Bogdanp/browser-connect.vim'
NeoBundle 'brookhong/cscope.vim'
NeoBundle 'majutsushi/tagbar'
NeoBundle 'myusuf3/numbers.vim'
NeoBundle 'rdolgushin/gitignore.vim'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'tomtom/tcomment_vim'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'tpope/vim-git'
NeoBundle 'tpope/vim-repeat'
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
    \     'unix': './install.sh',
    \     'mac': './install.sh',
    \   },
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

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General settings

" Map leader
let mapleader = ","

" Unlet g:color_names to avoid loading color scheme several times
" when sourcing ~/.virmc a second time. Several commands would trigger
" sourcing color scheme :syntax on and :set t_Co=256 and of course
" command :colorscheme itself.
if has('eval') | unlet! g:colors_name | endif

if has('multi_byte')
  scriptencoding utf-8
  set enc=utf-8
  set fileencodings=ucs-bom,utf-8,latin1
  if version >= 700
    set lcs=tab:»·,trail:·,eol:¶,extends:>,precedes:<,nbsp:×
  else
    set lcs=tab:»·,trail:·,eol:¶,extends:>,precedes:<
  endif
endif

if has('syntax') | syntax on | endif
if has('autocmd')
  filetype on
  filetype plugin on
endif

" Don't wait 1s when pressing <esc>
set timeout timeoutlen=3000 ttimeoutlen=100

set history=400
set textwidth=0
set backup
if has('persistent_undo')
  set undodir=~/UNDO
  set undofile
endif
if exists('+undoreload')  | set undoreload=100000    | endif
if exists('+cryptmethod') | set cryptmethod=blowfish | endif

set wildmode=longest,list
set wildmenu

set splitbelow
set hidden
set nostartofline
set backspace=indent,eol,start
set whichwrap+=<,>,[,]
set wrap
set showbreak=:
set laststatus=2
set noshowmode
set shiftwidth=4
set shiftround
set softtabstop=4
set autoindent
set smartindent
set expandtab
set ignorecase
set infercase
set smartcase
set cino:0
set comments=sr:/*,mb:*,ex:*/
set formatoptions=tcqor
" set showfulltag
if exists('+autochdir') | set autochdir | endif
set visualbell
if has('cmdline_info')
  set ruler
  set showcmd
endif
set nonumber
set showmatch
if has('extra_search')
  set hlsearch
  set incsearch
endif
set nolist
set matchpairs+=<:>
set virtualedit=block
set display=lastline,uhex
if has('eval')
  let g:lex_uses_cpp=1
  let g:yacc_uses_cpp=1
  let g:load_doxygen_syntax=1
  let g:is_posix=1
  let g:c_gnu=1
  let g:netrw_special_syntax=1
  let g:netrw_liststyle=3
  let g:netrw_browse_split=4
  let g:vimsyntax_noerror=1

  " Required to see the current function name in the status bar.
  let Tlist_Process_File_Always = 1

  " Configure HTML output with :TOhtml
  " let html_number_lines=1
  let html_use_css=1
  let html_use_xhtml=1
  let html_dynamic_folds=1

  " Set up for the CSApprox.vim plugin.
  let g:CSApprox_verbose_level = 0
  let g:CSApprox_attr_map = { 'bold' : 'bold', 'italic' : '', 'sp' : '' }
endif

set bg=dark

" Old paste macros
" nnoremap <F2> :set invpaste paste?<CR>
" imap <F2> <C-O><F2>
" set pastetoggle=<F2>

" This mapping allows to stay in visual mode when indenting with < and >
vnoremap > >gv
vnoremap < <gv

 map <F2>      :set paste!<CR>:set paste?<CR>
imap <F2> <C-O>:set paste<CR>:set paste?<CR>

if has('spell')
  map  <F8> :set spell!<CR>
endif

" Function used to display utf-8 sequence.
fun! ShowUtf8Sequence()
  try
    let p = getpos('.')
    redir => utfseq
    sil normal! g8
    redir End
    call setpos('.', p)
    return substitute(matchstr(utfseq, '\x\+ .*\x'), '\<\x', '0x&', 'g')
  catch
    return '?'
  endtry
endfunction

" Reload the .vimrc when it's written
if has('autocmd')
  au! BufWritePost ~/.vimrc nested source %

  " vim -b : edit binary using xxd-format
  " See :help hex-editing
  augroup Binary
    au!
    au BufReadPre   *.dat let &bin=1
    au BufReadPost  *.dat if  &bin   | %!xxd
    au BufReadPost  *.dat set ft=xxd | endif
    au BufWritePre  *.dat if  &bin   | %!xxd -r
    au BufWritePre  *.dat endif
    au BufWritePost *.dat if  &bin   | %!xxd
    au BufWritePost *.dat set nomod  | endif
  augroup END

  " Don't try to syntax highlight on a file over 512KB
  au BufReadPost * if getfsize(bufname("%")) > 512*1024 | 
    \ set syntax= |
    \ endif

endif

" Use modelines
set modeline
set modelines=5

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

"if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
"else
"  set backup		" keep a backup file
"endif
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" In an xterm the mouse should work quite well, thus enable it.
"set mouse=a

" This is an alternative that also works in block mode, but the deleted
" text is lost and it only works for putting the current register.
"vnoremap p "_dp

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Replace PageUp and PageDn with motion commands that don't screw
" with the cursor position.
map <silent> <PageUp> 1000<C-U>
map <silent> <PageDown> 1000<C-D>
imap <silent> <PageUp> <C-O>1000<C-U>
imap <silent> <PageDown> <C-O>1000<C-D>
set nostartofline

" Show help for keywords
au BufReadPost *.pl   set keywordprg=perldoc\ -f
au BufReadPost *.vim  map K :exe ":help ".expand("<cword>")<CR>
au BufReadPost .vimrc map K :exe ":help ".expand("<cword>")<CR>

" rastafari colorscheme available at:
"   http://dominique.pelle.free.fr/rastafari.vim
"   http://dominique.pelle.free.fr/rastafari.vim.html
:silent! colorscheme rastafari
:silent! colorscheme spectro

" Set GUI font used
if has("gui_running")
    if has("gui_macvim")
        set guifont=Essential\ PragmataPro:h12
    elseif has("gui_gtk2")
        set guifont=Essential\ PragmataPro\ 10
    endif
endif

" Enable line numbers and make them dark grey
set number
highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE gui=NONE guifg=DarkGrey guibg=NONE

" Powerline setup
set rtp+=~/.vim/bundle/powerline/powerline/bindings/vim
python from powerline.vim import setup as powerline_setup
python powerline_setup()
python del powerline_setup

" SnipMate mappings
:imap ,<Tab> <Plug>snipMateNextOrTrigger
:smap ,<Tab> <Plug>snipMateNextOrTrigger
