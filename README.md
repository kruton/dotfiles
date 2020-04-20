dotfiles ![Build status](https://github.com/kruton/dotfiles/workflows/CI/badge.svg) [![Test coverage](https://api.codeclimate.com/v1/badges/16aa5f62f533817d237d/test_coverage)](https://codeclimate.com/github/kruton/dotfiles/test_coverage)
========

My personal configuration files for my shell environment

To bootstrap this into a new shell environment:

    curl -sL https://raw.github.com/kruton/dotfiles/master/bootstrap.bash | bash -ex

or:

    wget -O - -o /dev/null https://raw.github.com/kruton/dotfiles/master/bootstrap.bash | bash -ex

If "sudo" access is not available, use the --no-sudo flag:

    curl -sL https://raw.github.com/kruton/dotfiles/master/bootstrap.bash | bash -ex /dev/stdin --no-sudo
