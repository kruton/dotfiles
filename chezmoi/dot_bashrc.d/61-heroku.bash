#!/usr/bin/env bash

# Add Heroku to the PATH if it is installed
if [ -d /usr/local/heroku/bin ]; then
    export PATH="/usr/local/heroku/bin:$PATH"
fi
