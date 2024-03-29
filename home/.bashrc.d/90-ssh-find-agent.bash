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
		IFS=':' read -r SSH_AUTH_SOCK _ <<< "$(_find_all_agent_sockets | tail -n 1)"
	fi
	export SSH_AUTH_SOCK
}

# vi: set shiftwidth=8 tabstop=8 expandtab:
