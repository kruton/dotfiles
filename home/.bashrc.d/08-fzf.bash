#!/usr/bin/env bash

# set up fzf

# shellcheck disable=SC2034
_gen_fzf_default_opts() {
    local base03="234"
    local base02="235"
    local base01="240"
    local base00="241"
    local base0="244"
    local base1="245"
    local base2="254"
    local base3="230"
    local yellow="136"
    local orange="166"
    local red="160"
    local magenta="125"
    local violet="61"
    local blue="33"
    local cyan="37"
    local green="64"

    # Solarized Dark color scheme for fzf
    export FZF_DEFAULT_OPTS="
      --color fg:-1,bg:-1,hl:$blue,fg+:$base2,bg+:$base02,hl+:$blue
      --color info:$yellow,prompt:$yellow,pointer:$base3,marker:$base3,spinner:$yellow
    "
}

_check_fzf_version() {
  # renovate: datasource=github-releases depName=junegunn/fzf
  local __fzf_version=0.57.0

  if [[ ! -x "$HOME/.fzf/bin/fzf" ]]; then \
    "$HOME/.fzf/install" --bin
  else \
    local __local_version
    read -r __local_version _ < <("$HOME/.fzf/bin/fzf" --version)
    if [[ ${__local_version% *} != $__fzf_version ]]; then \
      "$HOME/.fzf/install" --bin
    fi
  fi
}

if [[ -d "$HOME/.fzf/bin" ]]; then \
  _check_fzf_version
  export PATH="$PATH:$HOME/.fzf/bin"

  # shellcheck source=/dev/null
  #[[ $- == *i* ]] && source "$HOME/.fzf/shell/completion.bash" 2> /dev/null

  # shellcheck source=/dev/null
  source "$HOME/.fzf/shell/key-bindings.bash"

  _gen_fzf_default_opts

  if [[ ! -z "$ALL_HISTORY_FILE" && -f "$ALL_HISTORY_FILE" ]]; then
    # Get history.sh working with fzf
    bind '"\C-r": "\C-x1\e^\er"'
    bind -x '"\C-x1": __fzf_history__';

    __fzf_history__() {
      __ehc__ "$(
        while IFS=$'\t' read -r -d $'\0' _ _ _ cmd; do
          printf "%s" "$cmd"
        done < "$ALL_HISTORY_FILE" | fzf --tac --scheme=history --bind=ctrl-r:toggle-sort --wrap-sign '"$'\t'"↳ ' --highlight-line +m
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

unset -f _check_fzf_version
