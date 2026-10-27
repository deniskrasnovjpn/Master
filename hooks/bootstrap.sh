#!/bin/bash
# SessionStart hook. setup.sh copies it to ~/.claude/hooks/master-session-start.sh, where it stays
# frozen in the environment snapshot, so keep it minimal: it only updates the local copy of Master
# and runs hooks/session-start.sh from it. The real logic therefore changes with Master itself.
# If the fetch fails, the copy from the snapshot is used.
REPO="$HOME/.local/share/claude-master"
if [ -d "$REPO/.git" ]; then
  timeout 20 git -C "$REPO" fetch -q --depth 1 origin HEAD >/dev/null 2>&1 \
    && git -C "$REPO" reset -q --hard FETCH_HEAD >/dev/null 2>&1
fi
[ -f "$REPO/hooks/session-start.sh" ] && exec bash "$REPO/hooks/session-start.sh"
exit 0
