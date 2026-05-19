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

_debug_print() {
	if [[ $_DEBUG -gt 0 ]]
	then
		printf '%s\n' "$1"
	fi
}

_find_all_ssh_agent_sockets() {
	_SSH_AGENT_SOCKETS="$(find /tmp/ -type s -name agent.\* 2> /dev/null | grep '/tmp/ssh-.*/agent.*')"
	_debug_print "$_SSH_AGENT_SOCKETS"
}

_find_all_gpg_agent_sockets() {
	_GPG_AGENT_SOCKETS="$(find /tmp/ -type s -name S.gpg-agent.ssh 2> /dev/null | grep '/tmp/gpg-.*/S.gpg-agent.ssh')"
	_debug_print "$_GPG_AGENT_SOCKETS"
}

_find_all_gnome_keyring_agent_sockets() {
	_GNOME_KEYRING_AGENT_SOCKETS="$(find /tmp/ -type s -name ssh 2> /dev/null | grep '/tmp/keyring-.*/ssh$')"
	_debug_print "$_GNOME_KEYRING_AGENT_SOCKETS"
}

_find_all_osx_keychain_agent_sockets() {
	_OSX_KEYCHAIN_AGENT_SOCKETS="$(find /tmp/ -type s -regex '.*/launch-.*/Listeners$'  2> /dev/null)"
	_debug_print "$_OSX_KEYCHAIN_AGENT_SOCKETS"
}

_find_all_secretive_agent_sockets() {
	_SECRETIVE_AGENT_SOCKETS="$HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh"
	_debug_print "$_SECRETIVE_AGENT_SOCKETS"
}

_find_all_gnubby_agent_sockets() {
	_GNUBBY_AGENT_SOCKETS="$(find /tmp/ -type s -name agent.\* 2> /dev/null | grep "/tmp/agent.$USER.local/agent.*")"
	_debug_print "$_GNUBBY_AGENT_SOCKETS"
}

_test_agent_socket() {
	local SOCKET=$1
	SSH_AUTH_SOCK=$SOCKET $_SSH_ADD_BINARY -l 2> /dev/null > /dev/null
	result=$?

	_debug_print $result

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

_find_all_agent_sockets() {
	_LIVE_AGENT_LIST=
	_find_all_ssh_agent_sockets
	_find_all_gpg_agent_sockets
	_find_all_gnome_keyring_agent_sockets
	_find_all_osx_keychain_agent_sockets
	_find_all_gnubby_agent_sockets
	_find_all_secretive_agent_sockets
	_find_live_ssh_agents
	_find_live_gpg_agents
	_find_live_gnome_keyring_agents
	_find_live_osx_keychain_agents
	_find_live_gnubby_agents
	_find_live_secretive_agents
	_debug_print "$_LIVE_AGENT_LIST"
	printf '%s\n' "$_LIVE_AGENT_LIST" | tr ' ' $'\n' | sort -n -t: -k 2 -k 1
}

set_ssh_agent_socket() {
	if [[ -n $TMUX ]]; then
		IFS='=' read -r _ SSH_AUTH_SOCK <<< "$(tmux show-environment SSH_AUTH_SOCK)"
	else
		if ! _read_cached_ssh_agent_socket; then
			IFS=':' read -r SSH_AUTH_SOCK _ <<< "$(_find_all_agent_sockets | tail -n 1)"
			_write_cached_ssh_agent_socket
		fi
	fi
	export SSH_AUTH_SOCK
}

# vi: set shiftwidth=8 tabstop=8 expandtab:
