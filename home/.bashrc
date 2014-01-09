# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Get the base directory for this file to engage the "dotfiles" structure.
BASHRC_SOURCE="${BASH_SOURCE[0]}"
DOTFILES_DIR="$( dirname "$BASHRC_SOURCE" )"
while [ -h "$BASHRC_SOURCE" ]
do
  BASHRC_SOURCE="$(readlink "$BASHRC_SOURCE")"
  [[ $BASHRC_SOURCE != /* ]] && BASHRC_SOURCE="$DOTFILES_DIR/$BASHRC_SOURCE"
  DOTFILES_DIR="$( cd -P "$( dirname "$BASHRC_SOURCE"  )" && pwd )"
done
DOTFILES_DIR="$( cd -P "$( dirname "$BASHRC_SOURCE" )" && pwd )"

#
# Hack to get around gnome-terminal not being able to set its TERM
# to xterm-256color
#
if [ "$TERM" = "xterm" ] ; then
    if [ -z "$COLORTERM" ] ; then
        if [ -z "$XTERM_VERSION" ] ; then
            echo "Warning: Terminal wrongly calling itself 'xterm'."
        else
            case "$XTERM_VERSION" in
            "XTerm(256)") TERM="xterm-256color" ;;
            "XTerm(88)") TERM="xterm-88color" ;;
            "XTerm") ;;
            *)
                echo "Warning: Unrecognized XTERM_VERSION: $XTERM_VERSION"
                ;;
            esac
        fi
    else
        case "$COLORTERM" in
            gnome-terminal)
                # Those crafty Gnome folks require you to check COLORTERM,
                # but don't allow you to just *favor* the setting over TERM.
                # Instead you need to compare it and perform some guesses
                # based upon the value. This is, perhaps, too simplistic.
                TERM="gnome-256color"
                ;;
            *)
                echo "Warning: Unrecognized COLORTERM: $COLORTERM"
                ;;
        esac
    fi
fi

SCREEN_COLORS="`tput colors`"
if [ -z "$SCREEN_COLORS" ] ; then
    case "$TERM" in
        screen-*color-bce)
            echo "Unknown terminal $TERM. Falling back to 'screen-bce'."
            export TERM=screen-bce
            ;;
        *-88color)
            echo "Unknown terminal $TERM. Falling back to 'xterm-88color'."
            export TERM=xterm-88color
            ;;
        *-256color)
            echo "Unknown terminal $TERM. Falling back to 'xterm-256color'."
            export TERM=xterm-256color
            ;;
    esac
    SCREEN_COLORS=`tput colors`
fi
if [ -z "$SCREEN_COLORS" ] ; then
    case "$TERM" in
        gnome*|xterm*|konsole*|aterm|[Ee]term)
            echo "Unknown terminal $TERM. Falling back to 'xterm'."
            export TERM=xterm
            ;;
        rxvt*)
            echo "Unknown terminal $TERM. Falling back to 'rxvt'."
            export TERM=rxvt
            ;;
        screen*)
            echo "Unknown terminal $TERM. Falling back to 'screen'."
            export TERM=screen
            ;;
    esac
    SCREEN_COLORS=`tput colors`
fi

# a million lines in file history
export HISTFILESIZE=1000000
# a million lines in shell history
export HISTSIZE=1000000
# include timestamps in history printing
export HISTTIMEFORMAT="%F %T "
# ... and ignore same sucessive entries.
export HISTCONTROL=ignoreboth

# multiline commands in history as single line
shopt -s cmdhist

# append history file; don't overwrite
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color)
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    ;;
*)
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
    ;;
esac

# Comment in the above and uncomment this below for a color prompt
#PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'
    ;;
*)
    ;;
esac

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# Use vim if it's available. Otherwise fall back to "vi"
if [ ! -z "$(type -p vim)" ]; then \
    export EDITOR="vim"
elif [ ! -z "$(type -p vi)" ]; then \
    export EDITOR="vi"
fi

# Use gvim if we have a DISPLAY and it's available.
if [ ! -z "${DISPLAY}" -a ! -z "$(type -p gvim)" ]; then
    export VISUAL="gvim --nofork"
fi

export P4CONFIG=.p4config
export P4EDITOR=$EDITOR

export PAGER="less"
export LESS="-X -R -M --shift 5 -i"

export USE_CCACHE=1

export CCACHE_NLEVELS=4
export CCACHE_SLOPPINESS="time_macros"
export CCACHE_HARDLINK=1

export GREP_COLORS="ms=01;32:mc=01;32:sl=:cx=:fn=1;34:ln=1;32:bn=1;32:se=1;36"

# enable color support of ls and also add handy aliases
if [ "$TERM" != "dumb" ] && [ -x /usr/bin/dircolors ]; then \
    [ -e "$HOME/.dircolors" ] && DIR_COLORS="$HOME/.dircolors"
    [ -e "$DIR_COLORS" ] || DIR_COLORS=""
    eval "`dircolors -b $DIR_COLORS`"

    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Override any variables with local things before modules
if [ -f "${HOME}/.bashrc.local.pre" ]; then
    . "${HOME}/.bashrc.local.pre"
fi

# Source any modules from bashrc.d
for file in "${DOTFILES_DIR}/.bashrc.d"/*.bash; do
    . "${file}"
done

# Read in bash aliases
. "${DOTFILES_DIR}/.bash_aliases"

# Homeshick setup
source "$HOME/.homesick/repos/homeshick/homeshick.sh"
source "$HOME/.homesick/repos/homeshick/completions/homeshick-completion.bash"

# Override any variables with local things.
if [ -f "${HOME}/.bashrc.local" ]; then
    . "${HOME}/.bashrc.local"
fi
