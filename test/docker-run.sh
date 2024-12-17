#!/bin/bash

DETECTED_BASE="$(readlink -e "$(dirname $0)/..")"
REPO_BASE="${1:-$DETECTED_BASE}"

docker run --rm --security-opt seccomp=unconfined \
    -v "$REPO_BASE:$REPO_BASE" \
    -e TERM=xterm -t \
    --ulimit nofile=1024:1024 \
    kcov \
    kcov --clean --include-path="$REPO_BASE/" \
    --exclude-path="$REPO_BASE/test/,$REPO_BASE/bats/" \
    --strip-path="$REPO_BASE" \
    . \
    "$REPO_BASE/test/bats/bin/bats" --tap "$REPO_BASE/test"

perl -pi -e 's,/(</source>),\1,g' $REPO_BASE/coverage/bats/cobertura.xml
