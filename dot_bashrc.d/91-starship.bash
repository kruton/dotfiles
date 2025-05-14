_check_starship_version() {
    # renovate: datasource=github-releases depName=starship/starship
    local starship_version=1.23.0
    local current_version

    [[ -n $DEVSERVER ]] && return

    read -r _ current_version < <(starship --version)
    if [[ $current_version != "$starship_version" ]]; then \
        curl -sL "https://github.com/starship/starship/releases/download/v${starship_version}/starship-x86_64-unknown-linux-gnu.tar.gz" | tar zxfC - "$HOME/bin"
    fi
}

if command -v starship > /dev/null; then \
    if [[ $OSTYPE == linux-gnu ]]; then \
        _check_starship_version
    fi
    eval "$(starship init bash)"
fi

