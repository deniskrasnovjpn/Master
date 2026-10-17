#!/bin/bash
# Setup for Claude Code cloud sessions. The environment's "Setup script" field holds only
# the stub from setup-stub.sh: it clones this repo and runs this file at every session start.
# All setup commands go here; a failed step prints a warning and the session still starts.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
warn() { echo "WARNING: $*" >&2; }

# Global rules and skills
mkdir -p ~/.claude/skills
cp "$HERE/CLAUDE.md" ~/.claude/CLAUDE.md || warn "global CLAUDE.md not installed"
cp -r "$HERE/skills/." ~/.claude/skills/ || warn "global skills not installed"

# System tools: document conversion, fonts, OCR (German, Russian, English)
{ apt-get update -qq && apt-get install -y -qq --no-install-recommends \
    pandoc fonts-liberation \
    tesseract-ocr tesseract-ocr-deu tesseract-ocr-rus tesseract-ocr-eng; } \
  || warn "apt packages not installed"

# Python: PDF processing; zstd for Anki collection exports (.colpkg / .apkg)
python3 -m pip install -q --break-system-packages pymupdf zstandard \
  || warn "Python packages not installed"
