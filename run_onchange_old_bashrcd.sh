#!/bin/sh
# Add old files that are deleted from the repo


for f in \
        49-homebrew-path.bash \
        49-macports-path.bash \
        49-pip-local-user.bash \
        91-starship.bash \
        ; do \
    rm -f "$HOME/.bashrc.d/$f"
done
