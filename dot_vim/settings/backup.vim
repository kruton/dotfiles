" Keep generated Vim state out of project directories without disabling
" recovery or write safety.
let s:vim_state_home = expand('~/.vim/state')
let s:vim_swap_dir = s:vim_state_home . '/swap'
let s:vim_backup_dir = s:vim_state_home . '/backup'
let s:vim_undo_dir = s:vim_state_home . '/undo'

for s:vim_state_dir in [s:vim_swap_dir, s:vim_backup_dir, s:vim_undo_dir]
  call mkdir(s:vim_state_dir, 'p', 0700)
endfor

execute 'set directory=' . fnameescape(s:vim_swap_dir) . '//'
execute 'set backupdir=' . fnameescape(s:vim_backup_dir) . '//'

set swapfile
set backup
set writebackup

" Instead, keep undo history across sessions, by storing in file.
if has('persistent_undo')
  execute 'set undodir=' . fnameescape(s:vim_undo_dir) . '//'
  set undofile
  set undoreload=100000
endif
