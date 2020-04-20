#!/bin/bash

DETECTED_BASE="$(readlink -e "$(dirname $0)/..")"
REPO_BASE="${1:-$DETECTED_BASE}"

docker build "$REPO_BASE/test/kcov" \
          --build-arg UID="$(id -u)" \
          --build-arg GID="$(id -g)" \
          --build-arg WORKDIR="$REPO_BASE" \
          --tag kcov:latest
