#!/bin/sh
# Focus the neighbouring pane to the left or right; past the edge,
# switch to the previous/next tab instead.
set -eu

herdr=${HERDR_BIN_PATH:-herdr}
dir=$1
pane=$HERDR_ACTIVE_PANE_ID

if [ "$("$herdr" pane edges --pane "$pane" | jq -r ".result.edges.$dir")" != true ]; then
  exec "$herdr" pane focus --pane "$pane" --direction "$dir"
fi

case $dir in
  left) step=-1 ;;
  *) step=1 ;;
esac

# jq の負の添字は末尾から数えるので、両端で反対側に回り込む。
next=$("$herdr" tab list --workspace "$HERDR_ACTIVE_WORKSPACE_ID" |
  jq -r --arg cur "$HERDR_ACTIVE_TAB_ID" --argjson step "$step" \
    '.result.tabs | map(.tab_id) as $ids | $ids[(($ids | index($cur)) + $step) % length]')
[ "$next" = "$HERDR_ACTIVE_TAB_ID" ] || exec "$herdr" tab focus "$next"
