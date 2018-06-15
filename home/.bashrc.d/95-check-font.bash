#!/usr/bin/env bash

# Checks to see whether PragmataPro font is installed

# shellcheck disable=SC2154
if [[ -n $DISPLAY && -z $SSH_CLIENT && -z $debian_chroot ]]; then
  if command -v fc-list > /dev/null 2>&1; then
    if ! fc-list -q 'Essential PragmataPro:style=Regular'; then
      echo ""
      echo "!!! INSTALL Pragmata Pro font to ~/.fonts/"
      echo "   https://www.myfonts.com/my/orders/"
      echo ""
    fi
  fi
fi
