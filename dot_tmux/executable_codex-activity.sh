#!/usr/bin/env bash

# Activity monitoring is a window option: a Codex pane mutes the whole window.
# Keep explicit overrides (including "off") and inherited defaults distinct.
update_window() {
    local window=$1 commands saved original
    commands=$(tmux list-panes -t "$window" -F '#{pane_current_command}') || return
    saved=$(tmux show-options -wqv -t "$window" @codex_saved_monitor_activity)

    if [[ $'\n'"$commands"$'\n' == *$'\n'codex$'\n'* ]]; then
        if [[ -z $saved ]]; then
            original=$(tmux show-options -wqv -t "$window" monitor-activity)
            tmux set-option -w -t "$window" @codex_saved_monitor_activity "${original:-inherit}"
        fi
        tmux set-option -w -t "$window" monitor-activity off
    elif [[ -n $saved ]]; then
        if [[ $saved == inherit ]]; then
            tmux set-option -wu -t "$window" monitor-activity
        else
            tmux set-option -w -t "$window" monitor-activity "$saved"
        fi
        tmux set-option -wu -t "$window" @codex_saved_monitor_activity
    fi
}

if [[ ${1:-} == --watch ]]; then
    # tmux evaluates this small format internally once per second. The hook
    # runs only when the boolean changes, not on output, focus, or redraws.
    printf -v script_command '%q' "${BASH_SOURCE[0]}"
    # Older servers lack format monitors. Event hooks also cover startup
    # before the first monitor sample. The condition runs inside tmux, so
    # ordinary focus/layout/title events do not launch a shell.
    condition='#{!=:#{m:*1*,#{P:#{==:#{pane_current_command},codex}}},#{!=:#{@codex_saved_monitor_activity},}}'
    for event in window-renamed pane-focus-out after-select-pane window-layout-changed session-window-changed; do
        tmux set-hook -g "${event}[90]" \
            "if-shell -F '$condition' 'run-shell \"bash $script_command #{window_id}\"'"
    done
    while IFS= read -r session; do
        monitors=$(tmux show-hooks -B -t "$session" 2>/dev/null) || continue
        [[ $monitors == *'@codex-activity:'* ]] && continue
        tmux set-hook -t "$session" \
            -B '@codex-activity:@*:#{m:*1*,#{P:#{==:#{pane_current_command},codex}}}' \
            "run-shell \"bash $script_command #{hook_window}\""
    done < <(tmux list-sessions -F '#{session_id}')
    # Monitors record their first sample without firing. Reconcile once after
    # that sample in case Codex starts during startup or configuration reload.
    tmux run-shell -d 2 "bash $script_command"
    while IFS= read -r window; do
        update_window "$window"
    done < <(tmux list-windows -a -F '#{window_id}' | sort -u)
elif [[ -n ${1:-} ]]; then
    update_window "$1"
else
    # Also update existing windows when the configuration is reloaded.
    while IFS= read -r window; do
        update_window "$window"
    done < <(tmux list-windows -a -F '#{window_id}' | sort -u)
fi
