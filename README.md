dotfiles ![Build status](https://github.com/kruton/dotfiles/workflows/CI/badge.svg)
========

My personal configuration files for my shell environment.

To initialize on a new machine, download `chezmoi` according to one of the
methods detailed on [chezmoi install](https://www.chezmoi.io/install/) page.
After that, you can do:

```sh
chezmoi init kruton --ssh --apply
```

Package installation is configured for macOS (Homebrew), Fedora (dnf), and
Debian/Ubuntu (apt-get). Other systems do not receive automatic package
installation. macOS requires Homebrew to be installed first; Linux package
installation requires sudo access. The SSH bootstrap command also requires
working GitHub SSH authentication. Git and network access are needed to fetch
the repository, external tools, and editor plugins.

Review the proposed changes before applying on an existing machine:

```sh
chezmoi init kruton --ssh
chezmoi diff
chezmoi apply
```

Set `DEVSERVER=1` during initialization to install `.bashrc.dev` instead of
replacing `.bashrc`; source `~/.bashrc.dev` from the existing shell configuration.
Leave `DEVSERVER` unset for a normal installation (even `DEVSERVER=0` enables
the mode). This choice is saved in chezmoi's configuration.

Machine-specific overrides belong in these local files:

- `~/.bashrc.local.pre`: loaded before shell modules.
- `~/.bashrc.local`: loaded after shell modules and aliases.
- `~/.bash_profile.local`: loaded after `.bashrc` for login shells.
- `~/.gitconfig.local`: loaded after shared Git settings, so local values win.

Chezmoi creates a commented starter for `.gitconfig.local` if it is missing.
Existing contents and subsequent local edits are left alone.

Keep credentials and machine-specific secrets out of the source repository.
Tool versions live in `.chezmoiexternals/` and
`dot_config/mise/config.toml.tmpl`; OS packages live in `.chezmoidata/packages.yaml`.

To run the tests, initialize the test framework submodules and use Bats:

```sh
git submodule update --init --recursive
TERM=xterm-256color test/bats/bin/bats test/*.bats
```

Install chezmoi to exercise template and installation tests, and Neovim to
exercise its configuration tests. Template rendering downloads external
dependencies. The isolated installation test uses a temporary home and the real
shell/Git files and migration scripts; it does not install OS packages, download
tools, or install editor plugins. CI runs that test and portable shell helper
tests on Linux and macOS. The full suite, ShellCheck, coverage, and startup
performance comparison run on Linux.
