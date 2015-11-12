if [[ $OSTYPE == darwin* && -n $MP_PREFIX ]]; then
    # Put Homebrew BASH completion in
    if [ -f $MP_PREFIX/etc/profile.d/bash_completion.sh ]; then
        . $MP_PREFIX/etc/profile.d/bash_completion.sh
    fi
fi
