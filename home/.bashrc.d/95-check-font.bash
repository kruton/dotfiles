# Checks to see whether PragmataPro font is installed

if [[ -n $DISPLAY && -z $SSH_CLIENT ]]; then
  FC_LIST=$(which fc-list)
  if [[ -n ${FC_LIST} ]]; then
    ${FC_LIST} -q 'Essential PragmataPro:style=Regular'
    if [[ $? -ne 0 ]]; then
      echo ""
      echo "!!! INSTALL Pragmata Pro font to ~/.fonts/"
      echo "   https://www.myfonts.com/my/orders/"
      echo ""
    fi
  fi
fi
