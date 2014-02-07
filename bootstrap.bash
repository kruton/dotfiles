#!/bin/bash -ex

# Paste this into a terminal to install.
#   curl -sL https://raw.github.com/kruton/dotfiles/master/bootstrap.bash | bash -ex
#
# For OS X, install Xcode first if MacVim is needed.

### Detect the OS and distribution ###
case $OSTYPE in
  darwin*)
    platform="darwin"
    ;;
  linux*)
    LSBRELEASE=`which lsb_release`
    if [[ ! -x ${LSBRELEASE} ]]; then
       echo "Unknown Linux distro: lsb_release not found in path!"
       exit 1
    fi
    distro=${LSBRELEASE}
    case ${distro} in
       Fedora) platform="fedora" ;;
       Ubuntu) platform="ubuntu" ;;
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
if [[ ${platform} == "darwin" ]]; then
  ### Detect XCode tools
  ( gcc -v > /dev/null 2>&1 )
  ret=$?
  if [[ $ret -eq 69 ]]; then
    sudo xcodebuild -license
  elif [[ $ret -ne 0 ]]; then
    echo "Detected that XCode is not installed."
    echo "Follow on-screen instructions to install and restart script afterward."
    exit 1
  fi

  # Install Homebrew
  if ! which brew; then
    ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
  fi
  
  # Make sure Homebrew is first on the list
  export PATH=/usr/local/bin:${PATH}

  brew doctor
  if [[ $? -ne 0 ]]; then
    echo "*** FIX ALL HOMEBREW ERRORS FIRST: brew doctor"
    exit 1
  fi
  
  ### Install Homebrew packages ###
  brew install python
  
  # macvim requires full Xcode. vim just needs the CLI
  if [[ `xcode-select -p` == /Applications/Xcode.app* ]]; then
    brew install macvim --override-system-vim --with-lua
  else
    brew install vim --override-system-vi --with-lua
  fi
fi

### Prepare Fedora machines ###
if [[ ${platform} == "fedora" ]]; then
  sudo yum install python-pip git cmake gcc gcc-c++ python-devel
fi

# if Mac with Homebrew, omit --user
if [[ ${platform} != "darwin" ]]; then
  PIPFLAGS="--user"
fi
pip install ${PIPFLAGS} git+https://github.com/kruton/powerline

### Install homeshick ###
if [[ ! -e $HOME/.homesick/repos/homeshick ]]; then
  git clone https://github.com/andsens/homeshick.git $HOME/.homesick/repos/homeshick
fi
source $HOME/.homesick/repos/homeshick/homeshick.sh

### Check for private key ###
if ssh-add -l > /dev/null 2>&1; then
  repo="git@github.com:kruton/dotfiles"
else
  echo ""
  echo "*** WARNING: Install SSH key later and update dotfiles!"
  echo ""
  repo="https://github.com/kruton/dotfiles.git"
fi

homeshick --batch clone ${repo}

homeshick link --force

mv ~/.bash_history ~/.merged_bash_history
source ~/.bashrc

vim - +BundleInstall +BundleClean +qall < /dev/null

pushd ~/.vim/bundle/YouCompleteMe
[ -x ./install.sh ] && ./install.sh
popd
