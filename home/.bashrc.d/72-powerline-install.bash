# installs powerline if not installed

if [ ! -x $HOME/.local/bin/powerline ]; then \
    pip install --user --editable=$HOME/.homesick/repos/powerline
fi
