# Path to your oh-my-fish.
set fish_path $HOME/.oh-my-fish

# No need for the welcome banner
set fish_greeting

# Path to your custom folder (default path is ~/.oh-my-fish/custom)
set fish_custom $HOME/.homesick/repos/dotfiles/oh-my-fish

# Load oh-my-fish configuration.
. $fish_path/oh-my-fish.fish

. "$HOME/.homesick/repos/homeshick/homeshick.fish"

set fish_function_path $fish_function_path "$HOME/.vim/bundle/powerline/powerline/bindings/fish"
powerline-setup
