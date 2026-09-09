" Bridge Neovim to existing Vim configuration
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

" Disable providers for unused language runtimes
let g:loaded_node_provider = 0
let g:loaded_perl_provider = 0
let g:loaded_ruby_provider = 0

" Configure Python 3 provider if mise or python3 is available
if executable('mise')
  let s:mise_python = trim(system('mise which python3'))
  if filereadable(s:mise_python)
    let g:python3_host_prog = s:mise_python
  endif
elseif executable('python3')
  let g:python3_host_prog = exepath('python3')
endif

if filereadable(expand('~/.vimrc'))
  source ~/.vimrc
endif
