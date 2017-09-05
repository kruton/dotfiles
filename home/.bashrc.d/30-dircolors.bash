#!/usr/bin/env bash
# Sets DIR_COLORS, et al., if not already set.

if [[ -z $DIR_COLORS && -z $LS_COLORS ]]; then
	eval "$(dircolors)"
fi
