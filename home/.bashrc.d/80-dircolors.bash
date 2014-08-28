# solarized dircolors
if [ -d $HOME/.homesick/repos/dircolors-solarized ]; then
    if [[ $TERM == *-256color ]]; then
        eval `dircolors $HOME//.homesick/repos/dircolors-solarized/dircolors.256dark`
    fi
fi
