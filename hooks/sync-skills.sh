#!/bin/bash
# Brings ~/.claude/skills/ up to the skills of Master: the folders in skills/ plus the skills listed
# in skills-upstream.txt, fetched from their GitHub repositories (clones cached in
# ~/.local/share/claude-master-upstream/). Removes the skills it installed earlier that Master no
# longer has; skills from any other source are left alone. Run by setup.sh (baseline in the cloud
# snapshot) and by hooks/session-start.sh (every session, in the cloud and locally).
# Prints "true" on stdout if anything in ~/.claude/skills/ changed, otherwise "false"; logs go to stderr.
# If an upstream repository cannot be fetched, its cached clone is used, failing that the installed
# copy is kept, so a network failure never removes a skill.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS="$HOME/.claude/skills"
STATE="$HOME/.claude/.master-skills"   # skills installed from Master
CACHE="$HOME/.local/share/claude-master-upstream"
exec 3>&1 1>&2
warn() { echo "WARNING: $*" >&2; }

stage=$(mktemp -d) || { echo false >&3; exit 0; }
trap 'rm -rf "$stage"' EXIT

# Upstream skills: one shallow clone per repository, updated in place
if [ -f "$HERE/skills-upstream.txt" ]; then
  declare -A fetched=()
  while read -r repo path _; do
    [ -n "$repo" ] && [ "${repo#\#}" = "$repo" ] || continue
    name=$(basename "$path")
    clone="$CACHE/${repo//\//__}"
    if [ -z "${fetched[$repo]:-}" ]; then
      fetched[$repo]=1
      # core.longpaths: Windows paths over 260 characters; ignored elsewhere
      if [ -d "$clone/.git" ]; then
        err=$({ timeout 20 git -C "$clone" -c core.longpaths=true fetch -q --depth 1 origin HEAD \
          && git -C "$clone" -c core.longpaths=true reset -q --hard FETCH_HEAD; } 2>&1) \
          || warn "could not update $repo, using the cached copy: $err"
      else
        rm -rf "$clone" && mkdir -p "$CACHE"
        err=$(timeout 60 git -c core.autocrlf=false -c core.longpaths=true clone -q --depth 1 \
          "https://github.com/$repo.git" "$clone" 2>&1) \
          || { rm -rf "$clone"; warn "could not clone $repo: $err"; }
      fi
    fi
    if [ -d "$clone/$path" ]; then
      cp -r "$clone/$path" "$stage/$name"
    elif [ -d "$SKILLS/$name" ]; then
      warn "$repo has no $path, keeping the installed $name"
      cp -rL "$SKILLS/$name" "$stage/$name"
    else
      warn "$repo has no $path, $name not installed"
    fi
  done < "$HERE/skills-upstream.txt"
fi

# Master's own skills; on a name clash they win over upstream ones
if [ -d "$HERE/skills" ]; then
  for dir in "$HERE/skills"/*/; do
    [ -d "$dir" ] || continue
    rm -rf "$stage/$(basename "$dir")"
    cp -r "$dir" "$stage/"
  done
fi

changed=false
mkdir -p "$SKILLS"
current=$(find "$stage" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)
if [ -f "$STATE" ]; then
  while IFS= read -r name; do
    [ -n "$name" ] && [ -e "$SKILLS/$name" ] || continue
    grep -qxF -- "$name" <<<"$current" && continue
    rm -rf "${SKILLS:?}/$name" && changed=true
  done < "$STATE"
fi
while IFS= read -r name; do
  [ -n "$name" ] || continue
  [ ! -L "$SKILLS/$name" ] && diff -rq "$stage/$name" "$SKILLS/$name" >/dev/null 2>&1 && continue
  rm -rf "${SKILLS:?}/$name"
  cp -r "$stage/$name" "$SKILLS/$name" && changed=true
done <<<"$current"
printf '%s\n' "$current" > "$STATE"
echo "$changed" >&3
