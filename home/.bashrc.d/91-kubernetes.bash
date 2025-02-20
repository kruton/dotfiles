if [[ -x $HOME/bin/kubectl ]]; then
    # shellcheck disable=SC2142 # This should be less clever perhaps
    alias kx='f() { [[ "$1" ]] && kubectl config use-context $1 || kubectl config current-context ; } ; f'
    # shellcheck disable=SC2142 # This should be less clever perhaps
    alias kn='f() { [[ "$1" ]] && kubectl config set-context --current --namespace $1 || kubectl config view --minify | grep namespace | cut -d" " -f6 ; } ; f'

    # shellcheck disable=SC1090
    . <("$HOME/bin/kubectl" completion bash)
fi

_check_flux_version() {
    # renovate: datasource=github-releases depName=fluxcd/flux2 versioning=semver-coerced
    local __flux_version=2.5.0

    local __current_version
    __current_version="$("$HOME/bin/flux" --version)"
    if [[ $__flux_version != "${__current_version#flux version }" && $OSTYPE == linux-gnu ]]; then \
        url="https://github.com/fluxcd/flux2/releases/download/v${__flux_version}/flux_${__flux_version}_linux_amd64.tar.gz"
        curl -sL "$url" | tar zxfC - "$HOME/bin"
    fi
}

if [[ -x $HOME/bin/flux ]]; then
    _check_flux_version

    # shellcheck disable=SC1090
    . <("$HOME/bin/flux" completion bash)
fi

unset -f _check_flux_version
