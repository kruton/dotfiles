if [[ $OSTYPE == darwin* ]]; then
    # Put Homebrew BASH completion in
    if [ -f "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]; then
        . "$(brew --prefix)/etc/profile.d/bash_completion.sh"
    fi
fi
