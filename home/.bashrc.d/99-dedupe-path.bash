#!/usr/bin/env bash

# Deduplicate the PATH
PATH="$(dedupe_path_list "$PATH")"
export PATH
