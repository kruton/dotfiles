_check_starship_version() {
    # renovate: datasource=github-releases depName=starship/starship
    local starship_version=1.22.1
    local current_version

    read -r _ current_version < <(starship --version)
    if [[ $current_version != "$starship_version" ]]; then \
        curl -sL "https://github.com/starship/starship/releases/download/v${starship_version}/starship-x86_64-unknown-linux-gnu.tar.gz" | tar zxvfC - "$HOME/bin"
    fi
}

if command -v starship > /dev/null; then \
    if [[ $OSTYPE == linux-gnu ]]; then \
        _check_starship_version
    fi
    eval "$(starship init bash)"
fi

