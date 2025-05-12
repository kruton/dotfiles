#!/usr/bin/env bash
# Sets DIR_COLORS, et al., if not already set.

if [[ -z $DIR_COLORS && -z $LS_COLORS ]]; then
	if command -v gdircolors > /dev/null; then \
		eval "$(gdircolors)"
	else \
		eval "$(dircolors)"
	fi
fi
