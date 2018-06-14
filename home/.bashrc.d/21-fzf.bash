# set up fzf

if [[ -d "$HOME/.fzf/bin" ]]; then \
  export PATH="$PATH:$HOME/.fzf/bin"

  # shellcheck source=/dev/null
  [[ $- == *i* ]] && source "$HOME/.fzf/shell/completion.bash" 2> /dev/null

  # shellcheck source=/dev/null
  source "$HOME/.fzf/shell/key-bindings.bash"
fi
