if [ -x $HOME/bin/kubectl ]; then
    alias kx='f() { [ "$1" ] && kubectl config use-context $1 || kubectl config current-context ; } ; f'
    alias kn='f() { [ "$1" ] && kubectl config set-context --current --namespace $1 || kubectl config view --minify | grep namespace | cut -d" " -f6 ; } ; f'

    . <($HOME/bin/kubectl completion bash)
fi

if [ -x $HOME/bin/flux ]; then
    . <($HOME/bin/flux completion bash)
fi
