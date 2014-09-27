# For colorized files, use GNU ls when available.
if [[ $OSTYPE == darwin* &&  -x $(type -P gls) ]]; then
    alias ls="$(type -P gls) --color=auto"
fi
