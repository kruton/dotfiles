# All the castles I want
homeshick clone --quiet --batch git@github.com:kruton/dotfiles
homeshick clone --quiet --batch https://github.com/Shougo/neobundle.vim.git
homeshick clone --quiet --batch https://github.com/huyz/dircolors-solarized
homeshick clone --quiet --batch https://github.com/bpinto/oh-my-fish.git

#homeshick clone --quiet --batch https://github.com/ndbroadbent/scm_breeze.git
if [ -d $HOME/.homesick/repos/scm_breeze ]; then
  rm -rf $HOME/.homesick/repos/scm_breeze
fi
