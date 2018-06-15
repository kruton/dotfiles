#!/bin/bash

TEMPDIR="$(mktemp -d)"
LOG="$TEMPDIR/log"
TIMING="$TEMPDIR/timing"
JOINED="$TEMPDIR/joined"

env -i \
  HOME="$HOME" \
  LC_CTYPE="${LC_ALL:-${LC_CTYPE:-$LANG}}" \
  PATH="$PATH" \
  USER="$USER" \
  RUNNING_PERF="yes" \
  bash -l -i -x exit 2> >(
    tee "$LOG" | sed -u 's/^.*$/now/' | date -f - +%s.%N > "$TIMING"
  )

paste <(
    while read -r tim ;do
        [ -z "$last" ] && last=${tim//.} && first=${tim//.}
        crt=000000000$((${tim//.}-10#0$last))
        ctot=000000000$((${tim//.}-10#0$first))
        printf "%12.9f %12.9f\n" ${crt:0:${#crt}-9}.${crt:${#crt}-9} \
                                 ${ctot:0:${#ctot}-9}.${ctot:${#ctot}-9}
        last=${tim//.}
      done < "$TIMING"
  ) "$LOG" > "$JOINED"

echo Log at "$JOINED"
