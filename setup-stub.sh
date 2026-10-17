#!/bin/bash
# Paste this into the cloud environment's "Setup script" field (once).
# Everything else lives in setup.sh of deniskrasnovjpn/Master and is picked up by every new session.
if git clone -q --depth 1 https://github.com/deniskrasnovjpn/Master.git /tmp/master; then
  bash /tmp/master/setup.sh || echo "WARNING: Master/setup.sh failed" >&2
  rm -rf /tmp/master
else
  echo "WARNING: could not clone deniskrasnovjpn/Master; setup skipped" >&2
fi
