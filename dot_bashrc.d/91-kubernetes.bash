if command -v kubectl > /dev/null; then
    # shellcheck disable=SC2142 # This should be less clever perhaps
    alias kx='f() { [[ "$1" ]] && kubectl config use-context $1 || kubectl config current-context ; } ; f'
    # shellcheck disable=SC2142 # This should be less clever perhaps
    alias kn='f() { [[ "$1" ]] && kubectl config set-context --current --namespace $1 || kubectl config view --minify | grep namespace | cut -d" " -f6 ; } ; f'

    # shellcheck disable=SC1090
    . <(kubectl completion bash)
fi

if command -v flux > /dev/null; then
    # shellcheck disable=SC1090
    . <(flux completion bash)
fi
