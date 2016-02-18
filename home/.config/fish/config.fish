# Setup fisherman
set fisher_home ~/.local/share/fisherman
set fisher_config ~/.config/fisherman
source $fisher_home/config.fish

# No need for the welcome banner
set fish_greeting

# Setup homeshick shortcuts
. "$HOME/.homesick/repos/homeshick/homeshick.fish"

set POWERLINE_COMMAND_ARGS -t kruton.segment_data.user.args.hide_user="$DEFAULT_USER"
set fish_function_path $fish_function_path "$HOME/.vim/bundle/powerline/powerline/bindings/fish"
powerline-setup
