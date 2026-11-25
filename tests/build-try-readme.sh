#!/usr/bin/env bash
# Builds try/README.md from try/parts/*.md in course order (labs.txt).
# Usage: bash tests/build-try-readme.sh [--check]   (--check: fail if try/README.md is out of date)
set -eu
unset CDPATH
KIT="$(cd -P "$(dirname "$0")/.." && pwd)"
out="$(mktemp)"
{
  cat "$KIT/try/parts/_intro.md"
  last=""
  while IFS='|' read -r kind slug section minutes tier _goal; do
    case "$kind" in try) ;; *) continue ;; esac
    [ "$slug" = playground ] && continue
    [ -f "$KIT/try/parts/$slug.md" ] || { echo "missing try/parts/$slug.md" >&2; exit 1; }
    if [ "$section" != "$last" ]; then printf '\n## %s\n' "$section"; last="$section"; fi
    echo
    sed "1s/^### $slug\$/### $slug ($minutes min$([ "$tier" = if-time ] && echo ', if time'))/" "$KIT/try/parts/$slug.md"
  done < "$KIT/labs.txt"
} > "$out"
if [ "${1:-}" = --check ]; then
  if cmp -s "$out" "$KIT/try/README.md"; then rm -f "$out"; echo "try/README.md is up to date."; exit 0; fi
  rm -f "$out"; echo "try/README.md is out of date: run bash tests/build-try-readme.sh" >&2; exit 1
fi
mv "$out" "$KIT/try/README.md"
echo "Wrote try/README.md"
