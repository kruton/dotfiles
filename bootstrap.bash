#!/bin/bash -ex
#
# Paste this into a terminal to install.
#
#   curl -sL https://raw.github.com/kruton/dotfiles/master/bootstrap.bash | bash -ex
#
# or:
#   wget -O - -o /dev/null https://raw.github.com/kruton/dotfiles/master/bootstrap.bash | bash -ex
#
# If "sudo" access is not available, use:
#
#   curl -sL https://raw.github.com/kruton/dotfiles/master/bootstrap.bash | bash -ex /dev/stdin --no-sudo
#
# For OS X, install Xcode first if MacVim is needed.

# Script options
((sudo=0))

# Argument parsing
while getopts -- "-:" optchar; do
  case "${optchar}" in
    -)
      case "${OPTARG}" in
        no-sudo)
          ((sudo=1))
          ;;
      esac
      ;;
  esac
done

### Detect the OS and distribution ###
case $OSTYPE in
  darwin*)
    platform="darwin"
    ;;
  linux*)
    LSBRELEASE="$(which lsb_release)"
    if [[ -x ${LSBRELEASE} ]]; then
      distro="$( ${LSBRELEASE} -si )"
    elif [[ -f /etc/os-release ]]; then
      distro="$(. /etc/os-release; echo $NAME)"
    else
      echo "Unknown Linux distro: lsb_release not found in path!"
      exit 1
    fi
    case ${distro} in
       Fedora*) platform="fedora" ;;
       Ubuntu) platform="ubuntu" ;;
       Debian) platform="ubuntu" ;;
       *)
         echo "Unknown distro: ${distro}"
         exit 1
         ;;
    esac
    ;;
  *)
    echo "Unknown OS: $OSTYPE"
    exit 1
    ;;
esac

### Prepare MacOS X machines ###
if [[ ${platform} == darwin ]]; then
  if ((sudo)); then
    echo "You must have sudo on the Mac"
    exit 1
  fi

  ### Detect XCode tools
  ( gcc -v > /dev/null 2>&1 )
  (( ret = $? ))
  if (( ret == 69 )); then
    sudo xcodebuild -license
  elif (( ret != 0 )); then
    echo "Detected that XCode is not installed."
    echo "Follow on-screen instructions to install and restart script afterward."
    exit 1
  fi

  # Install Homebrew
  if ! which brew; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  fi
  
  # Make sure Homebrew is first on the list
  export PATH="/usr/local/bin:${PATH}"

  brew doctor
  if (( $? != 0 )); then
    echo "*** FIX ALL HOMEBREW ERRORS FIRST: brew doctor"
    exit 1
  fi
  
  ### Install Homebrew packages ###
  brew install python
  
  # macvim requires full Xcode. vim just needs the CLI
  if [[ $(xcode-select -p) == /Applications/Xcode.app* ]]; then
    brew install macvim --override-system-vim --with-lua
  else
    brew install vim --override-system-vi --with-lua
  fi
fi

### Prepare Fedora machines ###
if [[ ${platform} == fedora ]]; then
  if ((nosudo)); then
    echo "Fedora without sudo has not been tested yet."
    exit 1
  fi

  sudo dnf install -y python-pip git cmake gcc gcc-c++ python-devel
fi

### Prepare Ubuntu machines ###
if [[ ${platform} == ubuntu ]]; then
  if ((sudo)); then
    PIP="$(which pip)"
    if [[ ! -x ${PIP} ]]; then
      curl -sL https://raw.github.com/pypa/pip/master/contrib/get-pip.py | python /dev/stdin --user
    fi
  else
    sudo apt-get install python-pip git vim cmake python-dev default-jdk
  fi
fi

# if Mac with Homebrew, omit --user
if [[ ${platform} != darwin ]]; then
  PIPFLAGS="--user"
fi
pip install ${PIPFLAGS} git+https://github.com/kruton/powerline

### Install homeshick ###
if [[ ! -e $HOME/.homesick/repos/homeshick ]]; then
  git clone https://github.com/andsens/homeshick.git "$HOME/.homesick/repos/homeshick"
fi
source "$HOME/.homesick/repos/homeshick/homeshick.sh"

homeshick list | grep -q dotfiles
if (( $? != 0 )); then
  homeshick --batch clone https://github.com/kruton/dotfiles.git
  pushd $HOME/.homesick/repos/dotfiles
  git remote set-url --push origin git@github.com:kruton/dotfiles.git
  popd
fi

homeshick list | grep -q neobundle.vim || homeshick --batch clone https://github.com/Shougo/neobundle.vim.git

homeshick link --force

if [[ ! -f $HOME/.merged_bash_history ]]; then
  mv "$HOME/.bash_history" "$HOME/.merged_bash_history"
fi

source "$HOME/.bashrc"

vim - +NeoBundleInstall +NeoBundleClean +qall < /dev/null

pushd "$HOME/.vim/bundle/YouCompleteMe"
[ -x ./install.sh ] && ./install.sh
popd

# vim: set ts=2 sw=2 :
