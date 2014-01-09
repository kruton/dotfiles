# Checks to see whether PragmataPro font is installed

# This might work on MacOS, but I'd have to test it first.
if [[ "$OSTYPE" = "linux-gnu" ]]; then
  if [[ -n "$DISPLAY" ]]; then
    fc-list -q 'Essential PragmataPro:style=Regular'
    if [[ $? -ne 0 ]]; then
      echo ""
      echo "!!! INSTALL Pragmata Pro font to ~/.fonts/"
      echo "   https://www.myfonts.com/my/orders/"
      echo ""
    fi
  fi
fi
