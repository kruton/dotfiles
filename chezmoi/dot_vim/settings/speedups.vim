" Reload .vimrc and friends on write
au! BufWritePost ~/.vimrc nested source %
au! BufWritePost ~/.vim/settings/*.vim nested source ~/.vimrc
au! BufWritePost ~/.vim/settings.vim nested source ~/.vimrc

" Don't try to syntax highlight on a file over 512KB
au BufReadPost * if getfsize(bufname("%")) > 512*1024 |
  \ set syntax= |
  \ endif
