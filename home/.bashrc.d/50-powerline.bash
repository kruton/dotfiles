#!/usr/bin/env bash

_powerline_columns_fallback() {
	if which stty &>/dev/null ; then
		local cols="$(stty size 2>/dev/null)"
		if ! test -z "$cols" ; then
			echo "${cols#* }"
			return 0
		fi
	fi
	echo 0
	return 0
}

_powerline_tmux_setenv() {
	TMUX="$_POWERLINE_TMUX" tmux setenv -g TMUX_"$1"_`tmux display -p "#D" | tr -d %` "$2"
	TMUX="$_POWERLINE_TMUX" tmux refresh -S
}

_powerline_tmux_set_pwd() {
	if test "x$_POWERLINE_SAVED_PWD" != "x$PWD" ; then
		_POWERLINE_SAVED_PWD="$PWD"
		_powerline_tmux_setenv PWD "$PWD"
	fi
}

_powerline_tmux_set_columns() {
	_powerline_tmux_setenv COLUMNS "${COLUMNS:-`_powerline_columns_fallback`}"
}

_powerline_init_tmux_support() {
	if test -n "$TMUX" && tmux refresh -S &>/dev/null ; then
		# TMUX variable may be unset to create new tmux session inside this one
		_POWERLINE_TMUX="$TMUX"

		trap '_powerline_tmux_set_columns' WINCH
		_powerline_tmux_set_columns

		test "x$PROMPT_COMMAND" != "x${PROMPT_COMMAND/_powerline_tmux_set_pwd}" ||
			PROMPT_COMMAND="${PROMPT_COMMAND}"$'\n_powerline_tmux_set_pwd'
	fi
}

_powerline_local_prompt() {
	# Arguments: side, renderer_module arg, last_exit_code, jobnum, local theme
	"$POWERLINE_COMMAND" $POWERLINE_COMMAND_ARGS shell $1 \
		$2 \
		--last-exit-code=$3 \
		--jobnum=$4 \
		--renderer-arg="client_id=$$" \
		--renderer-arg="local_theme=$5"
}

# In case powerline is missing from PATH or something else
_powerline_fallback() {
	PS1="[powerline?] \u@\h \w\$ "
}

_powerline_prompt() {
	# Arguments: side, last_exit_code, jobnum
	"$POWERLINE_COMMAND" $POWERLINE_COMMAND_ARGS shell $1 \
		--width="${COLUMNS:-$(_powerline_columns_fallback)}" \
		-r.bash \
		--last-exit-code=$2 \
		--jobnum=$3 \
		-t kruton.segment_data.user.args.hide_user="$DEFAULT_USER" \
		--renderer-arg="client_id=$$"
}

_powerline_set_prompt() {
	if [[ -z $last_exit_code ]]; then
	    local last_exit_code=$?
	fi
	if [[ -n $POWERLINE_NO_SHELL_PROMPT$POWERLINE_NO_BASH_PROMPT ]]; then
		return $last_exit_code
	fi
	local jobnum="$(jobs -p|wc -l)"
	PS1="$(_powerline_prompt aboveleft $last_exit_code $jobnum)"
	if [[ $? -ne 0 ]]; then
		_powerline_fallback
	fi
	if test -n "$POWERLINE_SHELL_CONTINUATION$POWERLINE_BASH_CONTINUATION" ; then
		PS2="$(_powerline_local_prompt left -r.bash $last_exit_code $jobnum continuation)"
	fi
	if test -n "$POWERLINE_SHELL_SELECT$POWERLINE_BASH_SELECT" ; then
		PS3="$(_powerline_local_prompt left '' $last_exit_code $jobnum select)"
	fi
	return $last_exit_code
}

_powerline_setup_prompt() {
	VIRTUAL_ENV_DISABLE_PROMPT=1
	if test -z "${POWERLINE_COMMAND}" ; then
		POWERLINE_COMMAND="$("$POWERLINE_CONFIG_COMMAND" shell command)"
	fi
# BEGIN---kruton---kruton---kruton--- I use 99-prexec.sh instead of this
#	test "x$PROMPT_COMMAND" != "x${PROMPT_COMMAND%_powerline_set_prompt*}" ||
#		PROMPT_COMMAND=$'_powerline_set_prompt\n'"${PROMPT_COMMAND}"
# END---kruton---kruton---kruton--- I use 99-prexec.sh instead of this
        if [[ -z $POWERLINE_NO_SHELL_PROMPT$POWERLINE_NO_BASH_PROMPT ]]; then
		PS2="$(_powerline_local_prompt left -r.bash 0 0 continuation)"
		PS3="$(_powerline_local_prompt left '' 0 0 select)"
        fi
}

if test -z "${POWERLINE_CONFIG_COMMAND}" ; then
	if which powerline-config >/dev/null ; then
		POWERLINE_CONFIG_COMMAND=powerline-config
	else
		POWERLINE_CONFIG_COMMAND="$(dirname "$BASH_SOURCE")/../../../scripts/powerline-config"
	fi
fi

if "${POWERLINE_CONFIG_COMMAND}" shell --shell=bash uses prompt ; then
	_powerline_setup_prompt
fi
if "${POWERLINE_CONFIG_COMMAND}" shell --shell=bash uses tmux ; then
	_powerline_init_tmux_support
fi
