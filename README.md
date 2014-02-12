dotfiles
========

My personal configuration files for my shell environment

To bootstrap this into a new shell environment:

    curl -sL https://raw.github.com/kruton/dotfiles/master/bootstrap.bash | bash -ex

or:

    wget -O - -o /dev/null https://raw.github.com/kruton/dotfiles/master/bootstrap.bash | bash -ex

If "sudo" access is not available, use the --no-sudo flag:

    curl -sL https://raw.github.com/kruton/dotfiles/master/bootstrap.bash | bash -ex /dev/stdin --no-sudo
