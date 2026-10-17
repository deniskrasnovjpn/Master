#!/bin/bash
# Setup script for the Claude Code cloud environment.
# Paste this file's contents into the environment's "Setup script" field.
set -euo pipefail

# Global rules and skills from the Master repo
if git clone -q --depth 1 https://github.com/deniskrasnovjpn/Master.git /tmp/master; then
  mkdir -p ~/.claude/skills
  cp /tmp/master/CLAUDE.md ~/.claude/CLAUDE.md
  cp -r /tmp/master/skills/. ~/.claude/skills/
  rm -rf /tmp/master
else
  echo "WARNING: could not clone Master; global rules and skills are not installed" >&2
fi

# System tools: document conversion, fonts, OCR (German, Russian, English)
apt-get update -qq
apt-get install -y -qq --no-install-recommends \
  pandoc fonts-liberation \
  tesseract-ocr tesseract-ocr-deu tesseract-ocr-rus tesseract-ocr-eng

# Python: PDF processing; zstd for Anki collection exports (.colpkg / .apkg)
python3 -m pip install -q --break-system-packages pymupdf zstandard
