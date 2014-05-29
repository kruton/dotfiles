if [[ $OSTYPE == darwin* ]]; then
    # Put Homebrew BASH completion in
    if [ -f $(brew --prefix)/share/bash-completion/bash_completion ]; then
        . $(brew --prefix)/share/bash-completion/bash_completion
    fi
fi
