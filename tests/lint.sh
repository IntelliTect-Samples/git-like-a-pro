#!/usr/bin/env bash
# Portability lint: bans constructs that break on macOS's bash 3.2 or BSD tools.
# Also runs shellcheck when it's installed.
set -u
KIT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$KIT" || exit 2

files="lab lib/common.sh lib/doctor.sh $(ls labs/*/*.sh try/*.sh tests/solutions/*.sh tests/run-all.sh 2>/dev/null)"
status=0

# pattern%why
while IFS='%' read -r pattern why; do
  [ -n "$pattern" ] || continue
  # shellcheck disable=SC2086
  if hits="$(grep -nE -- "$pattern" $files)"; then
    echo "$why:"
    echo "$hits" | sed 's/^/  /'
    status=1
  fi
done <<'EOF'
sed -i%sed -i differs between GNU and BSD
(^|[^a-z_])(mapfile|readarray)([^a-z_]|$)%mapfile/readarray need bash 4
declare -A%associative arrays need bash 4
\$\{[A-Za-z_0-9]+(,|\^)%case conversion needs bash 4
(declare|local|typeset) -n%namerefs need bash 4.3
sort -[a-zA-Z]*V%sort -V is GNU-only
stat -c%stat -c is GNU-only (BSD uses -f)
xargs -r%xargs -r is GNU-only
sed -[a-zA-Z]*r%sed -r is GNU-only (use -E)
head -n -%negative head counts are GNU-only
cp --%long cp options are GNU-only
readlink -f%readlink -f is GNU-only
date -d%date -d is GNU-only
grep -[a-zA-Z]*P%grep -P is GNU-only
\|&%the |& operator needs bash 4
&>>%&>> needs bash 4
EOF

if command -v shellcheck >/dev/null 2>&1; then
  # shellcheck disable=SC2086
  shellcheck --shell=bash -S warning -e SC1090,SC1091,SC2034,SC2154,SC2155 $files || status=1
else
  echo "shellcheck not installed; skipped"
fi

[ "$status" -eq 0 ] && echo "Lint passed."
exit "$status"
