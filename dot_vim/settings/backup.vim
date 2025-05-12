" Turn off swap files. They clog up my working directories.
set noswapfile
set nobackup
set nowb

" Instead, keep undo history across sessions, by storing in file.
if has('persistent_undo')
  silent !mkdir ~/.vim/backups > /dev/null 2>&1
  set undodir=~/.vim/backups
  set undofile
  set undoreload=100000
endif
