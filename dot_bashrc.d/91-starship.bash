# renovate: datasource=github-releases depName=starship/starship
_starship_version=1.23.0

_download_starship() {
    [[ -n $DEVSERVER ]] && return

    curl -sL "https://github.com/starship/starship/releases/download/v${_starship_version}/starship-x86_64-unknown-linux-gnu.tar.gz" | tar zxfC - "$HOME/bin"
}

_check_starship_version() {
    local current_version

    [[ -n $DEVSERVER ]] && return

    read -r _ current_version < <(starship --version)
    if [[ $current_version != "$_starship_version" ]]; then \
        _download_starship
    fi
}

if command -v starship > /dev/null; then \
    if [[ $OSTYPE == linux-gnu ]]; then \
        _check_starship_version
    fi
    eval "$(starship init bash)"
fi

unset _starship_version
unset -f _check_starship_version
unset -f _download_starship
