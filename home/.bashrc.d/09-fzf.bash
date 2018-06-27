#!/usr/bin/env bash

# set up fzf

if [[ -d "$HOME/.fzf/bin" ]]; then \
  if [[ ! -x "$HOME/.fzf/bin/fzf" ]]; then \
    "$HOME/.fzf/install" --bin
  fi

  export PATH="$PATH:$HOME/.fzf/bin"

  # shellcheck source=/dev/null
  [[ $- == *i* ]] && source "$HOME/.fzf/shell/completion.bash" 2> /dev/null

  # shellcheck source=/dev/null
  source "$HOME/.fzf/shell/key-bindings.bash"

  if [[ ! -z "$ALL_HISTORY_FILE" && -f "$ALL_HISTORY_FILE" ]]; then
    # Get history.sh working with fzf
    bind '"\C-r": "\C-x1\e^\er"'
    bind -x '"\C-x1": __fzf_history__';

    __fzf_history__() {
      __ehc__ "$(
        while IFS=$'\t' read -r -d $'\0' _ _ _ cmd; do
          printf "%s" "$cmd"
        done < "$ALL_HISTORY_FILE" | fzf --tac --tiebreak=index
      )"
    }

    __ehc__() {
      if [[ -n $1 ]]; then
        bind '"\er": redraw-current-line'
        bind '"\e^": magic-space'
        READLINE_LINE=${READLINE_LINE:+${READLINE_LINE:0:READLINE_POINT}}${1}${READLINE_LINE:+${READLINE_LINE:READLINE_POINT}}
        READLINE_POINT=$(( READLINE_POINT + ${#1} ))
      else
        bind '"\er":'
        bind '"\e^":'
      fi
    }
  fi
fi
