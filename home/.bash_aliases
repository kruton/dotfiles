# Only if Android environment has been initialized.
if [ -d "${TOP}" ]; then
    alias a='cd "${TOP}"'
fi

# Only if ChromiumOS is initialized.
if [ -d $HOME/chromiumos ]; then
    alias c='cd "${HOME}/chromiumos"'
fi
