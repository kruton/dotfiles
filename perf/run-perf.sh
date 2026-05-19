#!/usr/bin/env bash

set -euo pipefail

samples=1
commit=''
compare_base=''
compare_target='HEAD'
max_regression_percent=20
max_regression_ms=100

usage() {
    cat <<'USAGE'
Usage:
  perf/run-perf.sh [--samples N] [--commit REF]
  perf/run-perf.sh --compare BASE [TARGET] [--samples N]

Options:
  --commit REF                  Benchmark Bash startup using dotfiles from REF.
  --compare BASE [TARGET]       Compare TARGET, default HEAD, against BASE.
  --samples N                   Run N samples and report the median. Default: 1.
  --max-regression-percent N    Allowed relative regression. Default: 20.
  --max-regression-ms N         Allowed absolute regression. Default: 100.
USAGE
}

while (($# > 0)); do
    case "$1" in
        --commit)
            commit="$2"
            shift 2
            ;;
        --compare)
            compare_base="$2"
            shift 2
            if (($# > 0)) && [[ $1 != --* ]]; then
                compare_target="$1"
                shift
            fi
            ;;
        --samples)
            samples="$2"
            shift 2
            ;;
        --max-regression-percent)
            max_regression_percent="$2"
            shift 2
            ;;
        --max-regression-ms)
            max_regression_ms="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown argument: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

if ! [[ $samples =~ ^[1-9][0-9]*$ ]]; then
    echo "--samples must be a positive integer" >&2
    exit 2
fi

repo_root="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

copy_source_file() {
    local source_root=$1
    local source_path=$2
    local target_path=$3

    if [[ -f $source_root/$source_path ]]; then
        mkdir -p "$(dirname "$target_path")"
        cp "$source_root/$source_path" "$target_path"
    fi
}

materialize_bash_home() {
    local source_root=$1
    local home=$2
    local source_path target_name

    mkdir -p "$home/.bashrc.d"

    copy_source_file "$source_root" dot_bash_profile "$home/.bash_profile"
    copy_source_file "$source_root" dot_bashrc "$home/.bashrc"
    copy_source_file "$source_root" dot_bash_aliases "$home/.bash_aliases"

    if [[ -d $source_root/dot_bashrc.d ]]; then
        for source_path in "$source_root"/dot_bashrc.d/*.bash; do
            [[ -e $source_path ]] || continue
            target_name="$(basename "$source_path")"
            if [[ $target_name == symlink_* ]]; then
                target_name="${target_name#symlink_}"
                : > "$home/.bashrc.d/$target_name"
            else
                cp "$source_path" "$home/.bashrc.d/$target_name"
            fi
        done
    fi
}

materialize_commit_home() {
    local ref=$1
    local tempdir=$2
    local source_root="$tempdir/source"
    local home="$tempdir/home"

    mkdir -p "$source_root" "$home"
    git -C "$repo_root" archive "$ref" | tar -x -C "$source_root"
    materialize_bash_home "$source_root" "$home"
    printf '%s\n' "$home"
}

run_one() {
    local home=$1
    local label=$2
    local tempdir log timing joined total

    tempdir="$(mktemp -d)"
    log="$tempdir/log"
    timing="$tempdir/timing"
    joined="$tempdir/joined"

    echo "Start $label" > "$log"

    env -i \
        HOME="$home" \
        LC_CTYPE="${LC_ALL:-${LC_CTYPE:-${LANG:-C.UTF-8}}}" \
        PATH="$PATH" \
        USER="${USER:-$(id -un)}" \
        RUNNING_PERF="yes" \
        bash -l -i -x -c exit 2> >(
            tee -a "$log" | sed -u 's/^.*$/now/' | date -f - +%s.%N > "$timing"
        )

    paste <(
        while read -r tim; do
            [[ -z ${last:-} ]] && last=${tim//.} && first=${tim//.}
            crt=000000000$((10#${tim//.} - 10#0$last))
            ctot=000000000$((10#${tim//.} - 10#0$first))
            printf "%12.9f %12.9f\n" "${crt:0:${#crt}-9}.${crt:${#crt}-9}" \
                "${ctot:0:${#ctot}-9}.${ctot:${#ctot}-9}"
            last=${tim//.}
        done < "$timing"
    ) "$log" > "$joined"

    total="$(awk 'NF >= 2 && $1 ~ /^[0-9.]+$/ { total=$2 } END { print total }' "$joined")"
    echo "Log for $label at $joined" >&2
    printf '%s\n' "$total"
}

median() {
    sort -n | awk '
        { values[NR] = $1 }
        END {
            if (NR == 0) {
                exit 1
            }
            if (NR % 2) {
                printf "%.9f\n", values[(NR + 1) / 2]
            } else {
                printf "%.9f\n", (values[NR / 2] + values[NR / 2 + 1]) / 2
            }
        }
    '
}

run_samples() {
    local ref=$1
    local label=$2
    local home=$HOME
    local tempdir=''
    local values sample

    values="$(mktemp)"
    if [[ -n $ref ]]; then
        tempdir="$(mktemp -d)"
        home="$(materialize_commit_home "$ref" "$tempdir")"
    fi

    for ((sample = 1; sample <= samples; sample++)); do
        run_one "$home" "$label sample $sample" >> "$values"
    done

    median < "$values"
}

if [[ -n $compare_base ]]; then
    base_time="$(run_samples "$compare_base" "$compare_base")"
    target_time="$(run_samples "$compare_target" "$compare_target")"
    allowed_time="$(awk -v base="$base_time" \
        -v percent="$max_regression_percent" \
        -v ms="$max_regression_ms" \
        'BEGIN {
            relative = base * (1 + percent / 100)
            absolute = base + (ms / 1000)
            printf "%.9f\n", (relative > absolute ? relative : absolute)
        }')"

    printf 'Bash startup median %s: %.3fs\n' "$compare_base" "$base_time"
    printf 'Bash startup median %s: %.3fs\n' "$compare_target" "$target_time"
    printf 'Allowed regression threshold: %.3fs\n' "$allowed_time"

    awk -v target="$target_time" -v allowed="$allowed_time" 'BEGIN { exit(target > allowed) }'
    exit $?
fi

if [[ -n $commit ]]; then
    run_samples "$commit" "$commit"
else
    run_samples '' current
fi
