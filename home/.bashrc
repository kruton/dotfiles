# This is just for migrating to chezmoi

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Get the base directory for this file to engage the "dotfiles" structure.
# From https://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
BASHRC_SOURCE="${BASH_SOURCE[0]}"
while [ -h "$BASHRC_SOURCE" ]; do
  DOTFILES_DIR="$( cd -P "$( dirname "$BASHRC_SOURCE" )" && pwd )"
  BASHRC_SOURCE="$(readlink "$BASHRC_SOURCE")"
  [[ $BASHRC_SOURCE != /* ]] && BASHRC_SOURCE="$DOTFILES_DIR/$BASHRC_SOURCE"
done
DOTFILES_DIR="$( cd -P "$( dirname "$BASHRC_SOURCE" )" && pwd )"

# Source any modules from bashrc.d
for file in "${DOTFILES_DIR}/.bashrc.d"/*.bash; do
    # shellcheck source=/dev/null
    [[ -f $file ]] && . "${file}"
done

