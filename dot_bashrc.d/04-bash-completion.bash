# -*- shell-script -*-

if [[ -n "$BASH_VERSION" && -z "$BASH_COMPLETION_COMPAT_DIR" ]]; then
    for file in \
        /etc/bash_completion \
            /usr/share/bash-completion/bash_completion \
            /usr/local/share/bash-completion/bash_completion; do
        if [[ -f "$file" ]]; then
            # shellcheck disable=SC1090
            source "$file" && break
        fi
    done
fi

# The next lines enables shell command completion and alias for brew.
if type brew &>/dev/null; then
  HOMEBREW_PREFIX="$(brew --prefix)"
  if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
      # shellcheck disable=SC1091
      source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
  else
      for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*; do
          # shellcheck disable=SC1090
          [[ -r "${COMPLETION}" ]] && source "${COMPLETION}"
      done
  fi
fi
