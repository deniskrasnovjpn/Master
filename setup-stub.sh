#!/bin/bash
# Paste this into the cloud environment's "Setup script" field. Everything else lives in setup.sh
# of deniskrasnovjpn/Master. The platform runs this field only when it builds the environment
# snapshot; new sessions start from the snapshot. Rules and skills need no rebuild (the hook that
# setup.sh installs updates them at every session start); after changing the tools in setup.sh,
# change the rev line below in the field so that the next session rebuilds the snapshot.
# rev 2026-10-27b
if git clone -q --depth 1 https://github.com/deniskrasnovjpn/Master.git /tmp/master; then
  bash /tmp/master/setup.sh || echo "WARNING: Master/setup.sh failed" >&2
  rm -rf /tmp/master
else
  echo "WARNING: could not clone deniskrasnovjpn/Master; setup skipped" >&2
fi
