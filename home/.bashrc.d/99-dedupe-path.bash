#!/usr/bin/env bash

# Deduplicate the PATH
export PATH="$(dedupe_path_list "$PATH")"
