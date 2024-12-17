_check_atuin_version() {
  # renovate: datasource=github-releases depName=atuinsh/atuin
  local __atuin_version=18.3.0

  if [[ -x "$HOME/bin/atuin" ]]; then \
    local __local_version
    read -r _ __local_version < <("$HOME/bin/atuin" --version)
    if [[ ${__local_version% *} != "$__atuin_version" ]]; then \
      # TODO: download new version automatically
      echo "New atuin version available: $__atuin_version"
    fi
  fi
}

if [[ -x $HOME/bin/atuin ]]; then \
    _check_atuin_version
    eval "$("$HOME/bin/atuin" init bash)"
fi

unset -f _check_atuin_version
