#!/bin/bash
# Setup for Claude Code cloud sessions. The environment's "Setup script" field holds only the stub
# from setup-stub.sh, which clones this repo and runs this file. The platform runs the field only
# when it builds the environment snapshot (the first session, a changed field or allowed hosts,
# the snapshot's expiry after about seven days); new sessions start from the snapshot without it.
# So this file installs the tools and a baseline copy of the rules and skills, plus a SessionStart
# hook (hooks/) that brings the rules and skills up to the current Master at every session start.
# A failed step prints a warning and the session still starts.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$HOME/.local/share/claude-master"
warn() { echo "WARNING: $*" >&2; }

# Global rules and skills (skills/ and the upstream ones from skills-upstream.txt): the baseline
# that the hook updates
mkdir -p ~/.claude
cp "$HERE/CLAUDE.md" ~/.claude/CLAUDE.md || warn "global CLAUDE.md not installed"
bash "$HERE/hooks/sync-skills.sh" >/dev/null || warn "global skills not installed"

# SessionStart hook: a copy of this repo for it to update, the hook script and its entry
# in ~/.claude/settings.json (merged: other keys and hooks stay)
if [ "$HERE" != "$REPO" ]; then
  { rm -rf "$REPO" && mkdir -p "$(dirname "$REPO")" && cp -a "$HERE" "$REPO"; } \
    || warn "copy of Master for the hook not made"
fi
{ mkdir -p ~/.claude/hooks && cp "$HERE/hooks/bootstrap.sh" ~/.claude/hooks/master-session-start.sh \
  && python3 - <<'PY'
import json
from pathlib import Path

path = Path.home() / ".claude" / "settings.json"
settings = json.loads(path.read_text(encoding="utf-8")) if path.exists() else {}
command = "bash ~/.claude/hooks/master-session-start.sh"
groups = settings.setdefault("hooks", {}).setdefault("SessionStart", [])
if not any(h.get("command") == command for g in groups for h in g.get("hooks", [])):
    groups.append({"hooks": [{"type": "command", "command": command, "timeout": 60}]})
path.write_text(json.dumps(settings, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
PY
} || warn "SessionStart hook not installed"

# System tools: document conversion, fonts, OCR (German, Russian, English)
{ apt-get update -qq && apt-get install -y -qq --no-install-recommends \
    pandoc fonts-liberation \
    tesseract-ocr tesseract-ocr-deu tesseract-ocr-rus tesseract-ocr-eng; } \
  || warn "apt packages not installed"

# Python: PDF processing; zstd for Anki collection exports (.colpkg / .apkg)
python3 -m pip install -q --break-system-packages pymupdf zstandard \
  || warn "Python packages not installed"

# Node CLIs for the obsidian plugin's skills: defuddle (web page → Markdown), knap (templates → notes)
npm install -g --no-fund --no-audit defuddle knap \
  || warn "npm packages not installed"
