_fetch_atuin() {
    local tag_name
    tag_name="$1"

    case "$OSTYPE" in
        darwin*)
            os_double="apple-darwin"
            ;;
        linux-gnu)
            os_double="unknown-linux-gnu"
            ;;
    esac

    if asset_url="$(curl -sL -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/atuinsh/atuin/releases | \
              jq -er '[.[] | select(.tag_name == "v'"$tag_name"'")][0].assets[] | select(.name | endswith("'"$HOSTTYPE-$os_double"'.tar.gz")).browser_download_url' 2> /dev/null)"; then \
        if ! curl -sL "$asset_url" | tar zxfC - "$HOME/bin" '*/atuin' --strip-components=1; then \
            echo "atuin: error extracting ${asset_url}"
        fi
    else \
        echo "atuin: error downloading ${asset_url}"
    fi
}

_check_atuin_version() {
    # renovate: datasource=github-releases depName=atuinsh/atuin
    local __atuin_version=18.4.0

    if [[ -x "$HOME/bin/atuin" ]]; then \
        local __local_version
        read -r _ __local_version < <("$HOME/bin/atuin" --version)
        if [[ ${__local_version% *} != "$__atuin_version" ]]; then \
            echo "atuin: new version available: $__atuin_version"
            _fetch_atuin "$__atuin_version"
        fi
    else \
        echo "atuin: installing..."
        _fetch_atuin "$__atuin_version"
    fi
}

_check_atuin_version
if [[ -x $HOME/bin/atuin ]]; then \
    eval "$("$HOME/bin/atuin" init bash --disable-up-arrow)"
fi

unset -f _check_atuin_version
unset -f _fetch_atuin
