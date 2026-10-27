#!/bin/bash
# Body of the SessionStart hook, run by hooks/bootstrap.sh from the freshly fetched copy of Master
# at every session start, resume, /clear and compaction. New sessions start from the environment
# snapshot, whose ~/.claude/CLAUDE.md and skills are those of the last snapshot build; this script
# brings the session up to the current Master:
# - copies changed skills into ~/.claude/skills/, removes the ones deleted from Master and asks
#   Claude Code to re-scan them (reloadSkills);
# - if CLAUDE.md differs from ~/.claude/CLAUDE.md, passes its current text to Claude as
#   additionalContext. The file itself is left as is: Claude Code has read it before the hook ran.
# Only the hook's JSON goes to stdout; everything else goes to stderr.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec 3>&1 1>&2

reload=false
state="$HOME/.claude/.master-skills"   # skills installed from Master, written by setup.sh
if [ -d "$HERE/skills" ]; then
  mkdir -p "$HOME/.claude/skills"
  current=$(find "$HERE/skills" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)
  if [ -f "$state" ]; then
    while IFS= read -r name; do
      [ -n "$name" ] && [ -d "$HOME/.claude/skills/$name" ] || continue
      grep -qxF -- "$name" <<<"$current" && continue
      rm -rf "${HOME:?}/.claude/skills/$name" && reload=true
    done < "$state"
  fi
  while IFS= read -r name; do
    [ -n "$name" ] || continue
    diff -rq "$HERE/skills/$name" "$HOME/.claude/skills/$name" >/dev/null 2>&1 && continue
    rm -rf "${HOME:?}/.claude/skills/$name"
    cp -r "$HERE/skills/$name" "$HOME/.claude/skills/$name" && reload=true
  done <<<"$current"
  printf '%s\n' "$current" > "$state"
fi

changed=false
[ -f "$HERE/CLAUDE.md" ] && ! cmp -s "$HERE/CLAUDE.md" "$HOME/.claude/CLAUDE.md" && changed=true

python3 - "$HERE/CLAUDE.md" "$reload" "$changed" >&3 <<'PY'
import json, sys
from pathlib import Path

rules, reload, changed = sys.argv[1], sys.argv[2] == "true", sys.argv[3] == "true"
LIMIT = 9800  # Claude Code moves additionalContext over 10,000 characters to a file
out, warning = {"hookEventName": "SessionStart"}, None
if changed:
    ctx = ("Актуальная версия глобальных правил пользователя: файл CLAUDE.md из репозитория "
           "deniskrasnovjpn/Master, подтянутый hook'ом SessionStart. Она полностью заменяет "
           "загруженный ~/.claude/CLAUDE.md — это устаревшая копия из снимка облачного окружения. "
           "Соблюдать эти правила с тем же приоритетом, что и CLAUDE.md.\n\n"
           + Path(rules).read_text(encoding="utf-8"))
    if len(ctx) > LIMIT:
        ctx = ("Актуальная версия глобальных правил пользователя (CLAUDE.md из репозитория "
               "deniskrasnovjpn/Master) слишком длинная для передачи hook'ом. Она лежит в "
               f"{rules} и полностью заменяет загруженный ~/.claude/CLAUDE.md — устаревшую копию "
               "из снимка облачного окружения. Прочитать этот файл целиком до начала работы "
               "и соблюдать его с тем же приоритетом, что и CLAUDE.md.")
        warning = (f"Master/CLAUDE.md вместе с заголовком длиннее {LIMIT} символов: hook передаёт "
                   "вместо правил ссылку на файл. Сократите CLAUDE.md.")
    out["additionalContext"] = ctx
if reload:
    out["reloadSkills"] = True
if len(out) > 1 or warning:
    result = {"hookSpecificOutput": out}
    if warning:
        result["systemMessage"] = warning
    print(json.dumps(result, ensure_ascii=False))
PY
exit 0
