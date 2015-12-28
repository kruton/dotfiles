#!/usr/bin/env bash

# Depends on ssh-find-agent
if [[ -z $SSH_AUTH_SOCK ]]; then
  set_ssh_agent_socket
fi
