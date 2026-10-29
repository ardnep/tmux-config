#!/usr/bin/env bash
set -euo pipefail

# Keep IDs hidden so names (including spaces and colons) are display-only.
# Unvisited windows sort last; their original session/index order is stable.
windows=$(tmux list-windows -a -F '#{?@tab_last_visit,#{@tab_last_visit},0}	#{session_id}:#{window_id}	#S:#I: #W' |
    sort -s -t $'\t' -k1,1nr | cut -f2-)

if ! selected=$(printf '%s\n' "$windows" | fzf-tmux -p -w 62% -h 38% -- \
    --no-multi --no-sort --delimiter=$'\t' --with-nth=2.. \
    --header='Select tab · most recently visited first' \
    --preview='tmux capture-pane -ep -t {1}' --preview-window=follow); then
    exit 0
fi

target=${selected%%$'\t'*}
[[ -n "$target" ]] || exit 0
# One operation selects both the session and window for the invoking client.
tmux switch-client -c "$1" -t "$target"
