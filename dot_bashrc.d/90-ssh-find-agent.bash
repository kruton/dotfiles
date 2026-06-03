#!/usr/bin/env bash

# Copyright (C) 2011 by Wayne Walker <wwalker@solid-constructs.com>
#
# Released under one of the versions of the MIT License.
#
# See LICENSE for details

_SOCAT_BINARY="$(command -v socat 2> /dev/null)"
_TIMEOUT_BINARY="$(command -v timeout 2> /dev/null)"
_SSH_ADD_BINARY="$(command -v ssh-add 2> /dev/null)"
if [[ -x $_TIMEOUT_BINARY && -x $_SSH_ADD_BINARY ]]; then
	_SSH_ADD_BINARY="$_TIMEOUT_BINARY 2 $_SSH_ADD_BINARY"
fi
_SSH_AGENT_CACHE_FILE=""

_LIVE_AGENT_LIST=""

_join_socket_lists() {
	printf '%s\n%s\n' "$1" "$2" | sed '/^$/d' | sort -u
}

_debug_print() {
	if [[ $_DEBUG -gt 0 ]]
	then
		printf '%s\n' "$1"
	fi
}

_find_all_ssh_agent_sockets() {
	_SSH_AGENT_SOCKETS="$(_find_home_ssh_agent_sockets)"
	_SSH_AGENT_SOCKETS="$(_join_socket_lists "$_SSH_AGENT_SOCKETS" "$(_find_xdg_ssh_agent_sockets)")"
	_debug_print "$_SSH_AGENT_SOCKETS"
}

_find_all_legacy_tmp_ssh_agent_sockets() {
	_SSH_AGENT_SOCKETS="$(_join_socket_lists "$_SSH_AGENT_SOCKETS" "$(find /tmp/ssh-* -maxdepth 1 -type s -name 'agent.*' 2> /dev/null)")"
	_debug_print "$_SSH_AGENT_SOCKETS"
}

_find_home_ssh_agent_sockets() {
	local agent_dir

	agent_dir="$HOME/.ssh/agent"
	[[ -d $agent_dir ]] || return 0

	find "$agent_dir" -maxdepth 1 -type s \( \
		-name 'agent.*' -o \
		-name 's.*.agent.*' -o \
		-name '*.sock' -o \
		-name '*ssh*' \
	\) 2> /dev/null
}

_find_xdg_ssh_agent_sockets() {
	[[ -n $XDG_RUNTIME_DIR && -d $XDG_RUNTIME_DIR && -O $XDG_RUNTIME_DIR ]] || return 0

	find "$XDG_RUNTIME_DIR" -maxdepth 4 -type s \( \
		-name 'agent.*' -o \
		-name 'ssh' \
	\) 2> /dev/null
}

_find_all_gpg_agent_sockets() {
	_GPG_AGENT_SOCKETS=
	if [[ -n $XDG_RUNTIME_DIR && -d $XDG_RUNTIME_DIR && -O $XDG_RUNTIME_DIR ]]; then
		_GPG_AGENT_SOCKETS="$(_join_socket_lists "$_GPG_AGENT_SOCKETS" "$(find "$XDG_RUNTIME_DIR/gnupg" -maxdepth 1 -type s -name S.gpg-agent.ssh 2> /dev/null)")"
	fi
	_debug_print "$_GPG_AGENT_SOCKETS"
}

_find_all_legacy_tmp_gpg_agent_sockets() {
	_GPG_AGENT_SOCKETS="$(_join_socket_lists "$_GPG_AGENT_SOCKETS" "$(find /tmp/gpg-* -maxdepth 1 -type s -name S.gpg-agent.ssh 2> /dev/null)")"
	_debug_print "$_GPG_AGENT_SOCKETS"
}

_find_all_legacy_tmp_gnome_keyring_agent_sockets() {
	_GNOME_KEYRING_AGENT_SOCKETS="$(find /tmp/keyring-* -maxdepth 1 -type s -name ssh 2> /dev/null)"
	_debug_print "$_GNOME_KEYRING_AGENT_SOCKETS"
}

_find_all_legacy_tmp_osx_keychain_agent_sockets() {
	_OSX_KEYCHAIN_AGENT_SOCKETS="$(_join_socket_lists "$_OSX_KEYCHAIN_AGENT_SOCKETS" "$(find /tmp/launch-* -maxdepth 1 -type s -name Listeners 2> /dev/null)")"
	_debug_print "$_OSX_KEYCHAIN_AGENT_SOCKETS"
}

_find_all_secretive_agent_sockets() {
	_SECRETIVE_AGENT_SOCKETS="$HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh"
	_debug_print "$_SECRETIVE_AGENT_SOCKETS"
}

_expand_ssh_identity_agent_path() {
	local path

	path="$1"
	path="${path%\"}"
	path="${path#\"}"
	path="${path%\'}"
	path="${path#\'}"

	case "$path" in
		none)
			return 1
			;;
		SSH_AUTH_SOCK)
			[[ -n $SSH_AUTH_SOCK ]] || return 1
			printf '%s\n' "$SSH_AUTH_SOCK"
			return 0
			;;
		\~)
			path="$HOME"
			;;
		\~/*)
			path="$HOME/${path#\~/}"
			;;
	esac

	path="${path//\%d/$HOME}"
	path="${path//\$\{HOME\}/$HOME}"
	path="${path//\$HOME/$HOME}"
	if [[ -n $SSH_AUTH_SOCK ]]; then
		path="${path//\$\{SSH_AUTH_SOCK\}/$SSH_AUTH_SOCK}"
		path="${path//\$SSH_AUTH_SOCK/$SSH_AUTH_SOCK}"
	fi
	if [[ -n $XDG_RUNTIME_DIR ]]; then
		path="${path//\$\{XDG_RUNTIME_DIR\}/$XDG_RUNTIME_DIR}"
		path="${path//\$XDG_RUNTIME_DIR/$XDG_RUNTIME_DIR}"
	fi

	printf '%s\n' "$path"
}

_find_ssh_config_identity_agent_sockets() {
	local config file identity_agent socket

	config="$HOME/.ssh/config"
	[[ -f $config ]] || return 0

	while IFS= read -r file
	do
		[[ -f $file ]] || continue
		while read -r keyword identity_agent _
		do
			case "$keyword" in
				[Ii][Dd][Ee][Nn][Tt][Ii][Tt][Yy][Aa][Gg][Ee][Nn][Tt])
					socket="$(_expand_ssh_identity_agent_path "$identity_agent")" || continue
					[[ -S $socket ]] && printf '%s\n' "$socket"
					;;
			esac
		done < <(sed 's/[[:space:]]*#.*$//' "$file")
	done < <(
		{
			printf '%s\n' "$config"
			while read -r keyword include_path _
			do
				case "$keyword" in
					[Ii][Nn][Cc][Ll][Uu][Dd][Ee])
						include_path="$(_expand_ssh_identity_agent_path "$include_path")" || continue
						# shellcheck disable=SC2086
						printf '%s\n' $include_path
						;;
				esac
			done < <(sed 's/[[:space:]]*#.*$//' "$config")
		} | sort -u
	)
}

_find_all_legacy_tmp_gnubby_agent_sockets() {
	_GNUBBY_AGENT_SOCKETS="$(_join_socket_lists "$_GNUBBY_AGENT_SOCKETS" "$(find "/tmp/agent.$USER.local" -maxdepth 1 -type s -name 'agent.*' 2> /dev/null)")"
	_debug_print "$_GNUBBY_AGENT_SOCKETS"
}

_test_agent_socket() {
	local SOCKET=$1
	SSH_AUTH_SOCK=$SOCKET $_SSH_ADD_BINARY -l 2> /dev/null > /dev/null
	result=$?

	_debug_print "$result"

	if [[ $result -eq 0 ]]
	then
		# contactible and has keys loaded
		_KEY_COUNT="$(SSH_AUTH_SOCK=$SOCKET $_SSH_ADD_BINARY -l | wc -l | tr -d ' ')"
	fi

	if [[ $result -eq 1 ]]
	then
		# contactible butno keys loaded
		_KEY_COUNT=0
	fi

	if [[ ( ( $result -eq 0 ) || ( $result -eq 1 ) ) ]]
	then
		if [[ -n "$_LIVE_AGENT_LIST" ]]
		then
			_LIVE_AGENT_LIST="${_LIVE_AGENT_LIST} ${SOCKET}:$_KEY_COUNT"
		else
			_LIVE_AGENT_LIST="${SOCKET}:$_KEY_COUNT"
		fi
		return 0
	fi

	return 1
}

_test_agent_socket_socat() {
	local SOCKET="$1"
	if [[ -x ${_SOCAT_BINARY} ]]
	then
		expected="$(echo -e '\x00\x00\x00\x01\x05')"
		response="$(echo -e '\x00\x00\x00\x01\xFF' | "${_SOCAT_BINARY}" - "UNIX-CONNECT:${SOCKET}" 2> /dev/null)"
		if [[ ${response} = "${expected}" ]]
		then
			if [[ -n "$_LIVE_AGENT_LIST" ]]
			then
				_LIVE_AGENT_LIST="${_LIVE_AGENT_LIST} ${SOCKET}:0"
			else
				_LIVE_AGENT_LIST="${SOCKET}:0"
			fi
			return 0
		fi
	fi
	return 1
}

_ssh_agent_socket_exists() {
	[[ -S $1 ]]
}

_ssh_agent_socket_is_live() {
	local live_agent_list result

	live_agent_list="$_LIVE_AGENT_LIST"
	_test_agent_socket "$1"
	result=$?
	_LIVE_AGENT_LIST="$live_agent_list"
	return "$result"
}

_ssh_agent_cache_dir() {
	local dir

	if [[ -n $XDG_RUNTIME_DIR && -d $XDG_RUNTIME_DIR && -O $XDG_RUNTIME_DIR ]]; then
		dir="$XDG_RUNTIME_DIR/dotfiles"
	else
		dir="${TMPDIR:-/tmp}/dotfiles-${UID}"
	fi

	if [[ -e $dir && ! -d $dir ]]; then
		return 1
	fi

	if [[ ! -d $dir ]]; then
		mkdir -m 700 "$dir" 2> /dev/null || return 1
	fi

	chmod 700 "$dir" 2> /dev/null || return 1
	[[ -O $dir ]] || return 1

	printf '%s\n' "$dir"
}

_ssh_agent_cache_file() {
	local dir

	if [[ -z $_SSH_AGENT_CACHE_FILE ]]; then
		dir="$(_ssh_agent_cache_dir)" || return 1
		_SSH_AGENT_CACHE_FILE="$dir/ssh-auth-sock"
	fi

	printf '%s\n' "$_SSH_AGENT_CACHE_FILE"
}

_stat_mode() {
	if stat -c '%a' "$1" > /dev/null 2>&1; then
		stat -c '%a' "$1"
	else
		stat -f '%Lp' "$1"
	fi
}

_stat_uid() {
	if stat -c '%u' "$1" > /dev/null 2>&1; then
		stat -c '%u' "$1"
	else
		stat -f '%u' "$1"
	fi
}

_ssh_agent_cache_file_is_private() {
	local cache_file mode mode_octal owner

	cache_file="$1"

	[[ -f $cache_file && ! -L $cache_file ]] || return 1

	mode="$(_stat_mode "$cache_file")" || return 1
	mode_octal=$((8#$mode))
	if (( mode_octal & 077 )); then
		return 1
	fi

	owner="$(_stat_uid "$cache_file")" || return 1
	[[ $owner == "$UID" ]] || return 1
}

_read_cached_ssh_agent_socket() {
	local cache_file socket

	cache_file="$(_ssh_agent_cache_file)" || return 1
	_ssh_agent_cache_file_is_private "$cache_file" || return 1

	IFS= read -r socket < "$cache_file" || return 1
	[[ -n $socket ]] || return 1
	_ssh_agent_socket_exists "$socket" || return 1

	SSH_AUTH_SOCK="$socket"
	return 0
}

_write_cached_ssh_agent_socket() {
	local cache_file tmp_file

	[[ -n $SSH_AUTH_SOCK ]] || return 1
	_ssh_agent_socket_exists "$SSH_AUTH_SOCK" || return 1

	cache_file="$(_ssh_agent_cache_file)" || return 1
	tmp_file="${cache_file}.$$"

	umask 077
	printf '%s\n' "$SSH_AUTH_SOCK" > "$tmp_file" || {
		rm -f "$tmp_file"
		return 1
	}
	chmod 600 "$tmp_file" 2> /dev/null || {
		rm -f "$tmp_file"
		return 1
	}
	mv -f "$tmp_file" "$cache_file"
}

_find_live_gnome_keyring_agents() {
	for i in $_GNOME_KEYRING_AGENT_SOCKETS
	do
		_test_agent_socket "$i"
	done
}

_find_live_secretive_agents() {
	for i in $_SECRETIVE_AGENT_SOCKETS
	do
		_test_agent_socket "$i"
	done
}

_find_live_osx_keychain_agents() {
	for i in $_OSX_KEYCHAIN_AGENT_SOCKETS
	do
		_test_agent_socket "$i"
	done
}

_find_live_gnubby_agents() {
	for i in $_GNUBBY_AGENT_SOCKETS
	do
		_test_agent_socket_socat "$i"
	done
}

_find_live_gpg_agents() {
	for i in $_GPG_AGENT_SOCKETS
	do
		_test_agent_socket "$i"
	done
}

_find_live_ssh_agents() {
	for i in $_SSH_AGENT_SOCKETS
	do
		_test_agent_socket "$i"
	done
}

_live_agent_list_has_keys() {
	printf '%s\n' "$_LIVE_AGENT_LIST" | grep -Eq ':[1-9][0-9]*( |$)'
}

_find_live_known_agents() {
	_find_live_ssh_agents
	_find_live_gpg_agents
	_find_live_gnome_keyring_agents
	_find_live_osx_keychain_agents
	_find_live_gnubby_agents
	_find_live_secretive_agents
	for i in $_SSH_CONFIG_AGENT_SOCKETS
	do
		_test_agent_socket "$i"
	done
}

_find_legacy_tmp_agent_sockets() {
	_find_all_legacy_tmp_ssh_agent_sockets
	_find_all_legacy_tmp_gpg_agent_sockets
	_find_all_legacy_tmp_gnome_keyring_agent_sockets
	_find_all_legacy_tmp_osx_keychain_agent_sockets
	_find_all_legacy_tmp_gnubby_agent_sockets
}

_find_live_legacy_tmp_agents() {
	_find_live_ssh_agents
	_find_live_gpg_agents
	_find_live_gnome_keyring_agents
	_find_live_osx_keychain_agents
	_find_live_gnubby_agents
}

_find_all_agent_sockets() {
	_LIVE_AGENT_LIST=
	_GNOME_KEYRING_AGENT_SOCKETS=
	_OSX_KEYCHAIN_AGENT_SOCKETS=
	_GNUBBY_AGENT_SOCKETS=
	_find_all_ssh_agent_sockets
	_find_all_gpg_agent_sockets
	_find_all_secretive_agent_sockets
	_SSH_CONFIG_AGENT_SOCKETS="$(_find_ssh_config_identity_agent_sockets)"
	_debug_print "$_SSH_CONFIG_AGENT_SOCKETS"
	_find_live_known_agents
	if ! _live_agent_list_has_keys; then
		_find_legacy_tmp_agent_sockets
		_find_live_legacy_tmp_agents
	fi
	_debug_print "$_LIVE_AGENT_LIST"
	printf '%s\n' "$_LIVE_AGENT_LIST" | tr ' ' $'\n' | sort -u -n -t: -k 2 -k 1
}

set_ssh_agent_socket() {
	local tmux_ssh_auth_sock

	if [[ -n $TMUX ]]; then
		IFS='=' read -r _ tmux_ssh_auth_sock <<< "$(tmux show-environment SSH_AUTH_SOCK 2> /dev/null)"
		if [[ -n $tmux_ssh_auth_sock ]] &&
			_ssh_agent_socket_exists "$tmux_ssh_auth_sock" &&
			_ssh_agent_socket_is_live "$tmux_ssh_auth_sock"; then
			SSH_AUTH_SOCK="$tmux_ssh_auth_sock"
			export SSH_AUTH_SOCK
			return 0
		fi
	fi

	if ! _read_cached_ssh_agent_socket; then
		IFS=':' read -r SSH_AUTH_SOCK _ <<< "$(_find_all_agent_sockets | tail -n 1)"
		_write_cached_ssh_agent_socket
	fi
	export SSH_AUTH_SOCK
}

# vi: set shiftwidth=8 tabstop=8 expandtab:
