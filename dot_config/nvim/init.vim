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

" Load local nvim-lambdamoo plugin if present
let s:nvim_lambdamoo = expand('~/git/nvim-lambdamoo')
if isdirectory(s:nvim_lambdamoo)
  execute 'set runtimepath+=' . fnameescape(s:nvim_lambdamoo)
  lua << EOF
  local ok, lambdamoo = pcall(require, "lambdamoo")
  if ok then
    lambdamoo.setup({
      connections = {
        {
          authority = "waterpoint",
          endpoint = "https://moo.waterpoint.org/dav/",
        },
        {
          authority = "codepoint",
          endpoint = "https://moo.codepoint.the-b.org/dav/",
        },
      },
    })
  end
EOF
endif

" Enable inlay hints if installed
lua << EOF
local ok, inlay_hints = pcall(require, "inlay-hints")
if ok then
  inlay_hints.setup({
    commands = { enable = true },  -- Enable commands: InlayHintsToggle, InlayHintsEnable, InlayHintsDisable
    autocmd = { enable = true },  -- Auto-enable inlay hints on LspAttach
  })
end
EOF
