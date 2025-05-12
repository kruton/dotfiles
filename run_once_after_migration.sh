#!/bin/sh

for f in "$HOME/.bashrc.d/"*; do
    if [ -L "$f" ] && [ ! -e "$f" ]; then \
        rm "$f"
    fi
done
