#!/usr/bin/env bash
# Tests every lab and Try-it: builds, determinism, checks, solutions, safety.
# Run from anywhere: bash tests/run-all.sh   (uses a temporary LAB_HOME; never touches ~/git-labs)
set -u
unset CDPATH

# Every inner call uses "$BASH" (the bash running this script), so "/bin/bash tests/run-all.sh"
# on macOS tests bash 3.2 all the way down. UPDATE_GOLDEN=1 rewrites tests/expected-refs.txt.
KIT="$(cd -P "$(dirname "$0")/.." && pwd)"
LAB="$KIT/lab"
TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "${TMP_ROOT:?}"' EXIT
export LAB_HOME="$TMP_ROOT/lab home" # a space on purpose: paths with spaces must work
FAILED=0

pass() { echo "ok    $*"; }
fail() { echo "FAIL  $*"; FAILED=1; }
expect_ok()   { local what="$1"; shift; if "$@" >"$TMP_ROOT/out" 2>&1; then pass "$what"; else fail "$what"; sed 's/^/      /' "$TMP_ROOT/out"; fi; }
expect_code() { local code="$1" what="$2" rc; shift 2; "$@" >"$TMP_ROOT/out" 2>&1; rc=$?
  if [ "$rc" -eq "$code" ]; then pass "$what"; else fail "$what (exit $rc, wanted $code)"; sed 's/^/      /' "$TMP_ROOT/out"; fi; }

global_config_hash() { git config --global --list 2>/dev/null | git hash-object --stdin; }
BEFORE="$(global_config_hash)"

echo "Kit: $KIT"
echo "Git: $(git --version)   bash: $BASH_VERSION   $(uname -s)"
echo

# ---------------------------------------------------------------- tool basics
expect_ok "lab help" "$BASH" "$LAB" help
expect_ok "lab version" "$BASH" "$LAB" version
expect_ok "lab list" "$BASH" "$LAB" list
expect_code 1 "unknown lab is a user error" "$BASH" "$LAB" no-such-lab
expect_code 1 "unknown Try-it is a user error" "$BASH" "$LAB" try no-such-try
"$BASH" "$LAB" doctor >"$TMP_ROOT/out" 2>&1
case $? in 0|2) pass "lab doctor runs" ;; *) fail "lab doctor crashed"; sed 's/^/      /' "$TMP_ROOT/out" ;; esac

# ---------------------------------------------------------------- registry
while IFS='|' read -r kind slug _rest; do
  case "$kind" in ""|\#*) continue ;; esac
  if [ "$kind" = lab ]; then f="$KIT/labs/$slug/setup.sh"; else f="$KIT/try/$slug.sh"; fi
  [ -f "$f" ] && pass "registry: $kind $slug is built"
done < "$KIT/labs.txt"
for f in "$KIT"/try/*.sh; do
  s="$(basename "$f" .sh)"
  grep -q "^try|$s|" "$KIT/labs.txt" || fail "try/$s.sh is missing from labs.txt"
done
for d in "$KIT"/labs/*/; do
  s="$(basename "$d")"
  grep -q "^lab|$s|" "$KIT/labs.txt" || fail "labs/$s is missing from labs.txt"
done

ws_repos() { # every repo in a workspace: the folder itself and its direct children (bare ones too)
  local d
  for d in "$1" "$1"/*; do
    if [ -d "$d/.git" ] || [ -f "$d/HEAD" ]; then echo "$d"; fi
  done
}
ws_refs() { ws_repos "$1" | while IFS= read -r r; do git -C "$r" rev-parse --all; done | git hash-object --stdin; }
ws_dirty() { ws_repos "$1" | while IFS= read -r r; do if [ -d "$r/.git" ]; then git -C "$r" status --porcelain; fi; done; }
ws_marker_commits() {
  ws_repos "$1" | while IFS= read -r r; do
    if [ -d "$r/.git" ]; then git -C "$r" log --all --format= --name-only | grep -x '.git-lab-workspace'; fi
  done
}
golden() { # golden <workspace>: "workspace/repo ref hash" lines, compared across OSes via tests/expected-refs.txt
  ws_repos "$LAB_HOME/$1" | while IFS= read -r r; do
    git -C "$r" for-each-ref --format="$1${r#"$LAB_HOME/$1"} %(refname) %(objectname)"
  done
}
: > "$TMP_ROOT/refs.txt"
SKIPPED_WS=""

# ---------------------------------------------------------------- Try-its
for f in "$KIT"/try/*.sh; do
  s="$(basename "$f" .sh)"
  if [ "$s" = playground ]; then cmd="play"; ws="playground"; else cmd="try $s"; ws="try-$s"; fi
  # shellcheck disable=SC2086
  expect_ok "try $s builds" "$BASH" "$LAB" $cmd
  h1="$(ws_refs "$LAB_HOME/$ws")"
  # shellcheck disable=SC2086
  "$BASH" "$LAB" $cmd >/dev/null 2>&1
  h2="$(ws_refs "$LAB_HOME/$ws")"
  if [ -n "$(ws_repos "$LAB_HOME/$ws")" ] && [ "$h1" = "$h2" ]; then pass "try $s is deterministic"; else fail "try $s rebuild changed refs (or built no repo)"; fi
  dirty_ok="$( . "$f"; echo "${TRY_DIRTY:-}" )"
  if [ -n "$dirty_ok" ]; then pass "try $s starts with changes on purpose (TRY_DIRTY)"
  elif [ -z "$(ws_dirty "$LAB_HOME/$ws")" ]; then pass "try $s starts clean"; else fail "try $s has a dirty working tree"; fi
  if [ -n "$(ws_marker_commits "$LAB_HOME/$ws")" ]; then fail "try $s committed .git-lab-workspace"; else pass "try $s never commits the kit's marker file"; fi
  golden "$ws" >> "$TMP_ROOT/refs.txt"
done

# ---------------------------------------------------------------- labs
solve_lab() { # solve_lab <slug> <step>: run the test fixture in the workspace
  ( . "$KIT/lib/common.sh"; . "$KIT/labs/$1/setup.sh"; . "$KIT/tests/solutions/$1.sh"
    begin_build; cd "$LAB_HOME/$1" && solve_from "$2" )
}

for labdir in "$KIT"/labs/*/; do
  d="$labdir"
  s="$(basename "$d")"
  [ -f "$d/setup.sh" ] || continue
  steps="$( . "$d/setup.sh"; echo "$LAB_STEPS" )"
  rooms="$( . "$d/setup.sh"; echo "${LAB_ROOMS:-}" )"
  needs="$( . "$d/setup.sh"; echo "${LAB_NEEDS:-}" )"
  if [ "$needs" = git-lfs ] && ! git lfs version >/dev/null 2>&1; then
    echo "skip  lab $s needs git-lfs, which isn't installed"
    expect_code 2 "lab $s says clearly that git-lfs is missing" "$BASH" "$LAB" "$s"
    SKIPPED_WS="$SKIPPED_WS $s"
    continue
  fi
  expect_ok "lab $s builds" "$BASH" "$LAB" "$s"
  h1="$(ws_refs "$LAB_HOME/$s")"
  "$BASH" "$LAB" "$s" >/dev/null 2>&1
  h2="$(ws_refs "$LAB_HOME/$s")"
  [ "$h1" = "$h2" ] && pass "lab $s is deterministic ($(ws_repos "$LAB_HOME/$s" | wc -l | tr -d ' ') repos)" || fail "lab $s rebuild changed refs"
  [ -z "$(ws_dirty "$LAB_HOME/$s")" ] && pass "lab $s starts clean" || fail "lab $s has a dirty working tree"
  golden "$s" >> "$TMP_ROOT/refs.txt"
  [ -z "$(ws_marker_commits "$LAB_HOME/$s")" ] && pass "lab $s never commits the kit's marker file" || fail "lab $s committed .git-lab-workspace"
  if [ -f "$d/check.sh" ]; then
    expect_code 1 "lab $s: a fresh build fails --check" "$BASH" "$LAB" "$s" --check
  fi
  final_tree=""
  step=1
  while [ "$step" -le "$steps" ]; do
    expect_ok "lab $s --step $step builds" "$BASH" "$LAB" "$s" --step "$step"
    if [ -f "$KIT/tests/solutions/$s.sh" ]; then
      expect_ok "lab $s: solved from step $step" solve_lab "$s" "$step"
      [ -f "$d/check.sh" ] && expect_ok "lab $s: --check passes after solving from step $step" "$BASH" "$LAB" "$s" --check
      if [ -d "$LAB_HOME/$s/.git" ]; then
        tree="$(git -C "$LAB_HOME/$s" rev-parse 'HEAD^{tree}')"
        if [ -z "$final_tree" ]; then final_tree="$tree"
        elif [ "$tree" = "$final_tree" ]; then pass "lab $s: step $step ends with the same files as step 1"
        else fail "lab $s: step $step ends with different files than step 1"; fi
      fi
    fi
    step=$((step + 1))
  done
  if [ -n "$rooms" ]; then # rebuilding one room resets only that room
    n=1
    while [ "$n" -le "$rooms" ]; do
      expect_ok "lab $s --room $n rebuilds" "$BASH" "$LAB" "$s" --room "$n"
      "$BASH" "$LAB" "$s" --check >"$TMP_ROOT/out" 2>&1; rc=$?
      notyet="$(grep '\[not yet\]' "$TMP_ROOT/out")"
      if [ "$rc" -eq 1 ] && [ -n "$notyet" ] && ! printf '%s\n' "$notyet" | grep -qv "Room $n:"; then
        pass "lab $s: --room $n reset only room $n"
      else
        fail "lab $s: --room $n (exit $rc)"; sed 's/^/      /' "$TMP_ROOT/out"
      fi
      ( . "$KIT/lib/common.sh"; . "$d/setup.sh"; . "$KIT/tests/solutions/$s.sh"; begin_build; cd "$LAB_HOME/$s" && solve_room "$n" ) >/dev/null 2>&1
      expect_ok "lab $s: --check passes again after solving room $n" "$BASH" "$LAB" "$s" --check
      n=$((n + 1))
    done
    expect_code 1 "bad room number is a user error" "$BASH" "$LAB" "$s" --room 99
  fi
  expect_ok "lab $s hint list" "$BASH" "$LAB" hint "$s"
  expect_ok "lab $s hint 1" "$BASH" "$LAB" hint "$s" 1
done

# ---------------------------------------------------------------- safety
mkdir -p "$LAB_HOME/reviewable-not-ours"
mkdir -p "$TMP_ROOT/elsewhere"
# a folder the kit didn't make must never be deleted
rm -rf "${LAB_HOME:?}/reviewable"; mkdir -p "$LAB_HOME/reviewable"; echo keep > "$LAB_HOME/reviewable/precious.txt"
expect_code 2 "refuses to wipe a folder it didn't make" "$BASH" "$LAB" reviewable
[ -f "$LAB_HOME/reviewable/precious.txt" ] && pass "unmarked folder left alone" || fail "unmarked folder was deleted"
rm -rf "${LAB_HOME:?}/reviewable"
"$BASH" "$LAB" reviewable >/dev/null 2>&1
( cd "$LAB_HOME/reviewable" && "$BASH" "$LAB" reviewable ) >"$TMP_ROOT/out" 2>&1
[ $? -eq 1 ] && pass "refuses to wipe the folder you're standing in" || fail "wiped the current folder"
expect_code 1 "bad step number is a user error" "$BASH" "$LAB" reviewable --step 9
expect_code 2 "refuses LAB_HOME=/" env LAB_HOME=/ "$BASH" "$LAB" reviewable
expect_code 2 "refuses LAB_HOME=\$HOME" env LAB_HOME="$HOME" "$BASH" "$LAB" reviewable
"$BASH" "$LAB" reviewable --step 02 >/dev/null 2>&1
[ "$(git -C "$LAB_HOME/reviewable" rev-list --count main..discounts 2>/dev/null)" = 3 ] && pass "--step 02 means step 2" || fail "--step 02 built the wrong state"
env LAB_HOME="$TMP_ROOT/doctor-new" "$BASH" "$LAB" doctor >/dev/null 2>&1
[ ! -e "$TMP_ROOT/doctor-new" ] && pass "doctor creates nothing" || fail "doctor created the workspace folder"

# WSL against a Windows folder: refuse to build, and doctor says why
if env LAB_TEST_WSL=1 LAB_HOME="$TMP_ROOT/wsl" "$BASH" "$LAB" try playground >"$TMP_ROOT/out" 2>&1; then
  fail "lab ran under (simulated) WSL against a Windows folder"
elif grep -q "lab.cmd" "$TMP_ROOT/out" && [ ! -e "$TMP_ROOT/wsl" ]; then pass "WSL against a Windows folder: refuses and says to use lab.cmd or Git Bash"
else fail "WSL refusal message missing, or it built something"; sed 's/^/      /' "$TMP_ROOT/out"; fi
env LAB_TEST_WSL=1 "$BASH" "$LAB" doctor 2>&1 | grep -q "PROBLEM.*WSL" && pass "doctor flags WSL against a Windows folder" || fail "doctor didn't flag WSL"
mkdir -p "$LAB_HOME/.trash-old-1"; echo x > "$LAB_HOME/.trash-old-1/f"
"$BASH" "$LAB" play >/dev/null 2>&1
[ ! -e "$LAB_HOME/.trash-old-1" ] && pass "leftover .trash folders are swept" || fail ".trash folder left behind"
if command -v cygpath >/dev/null 2>&1; then
  expect_ok "LAB_HOME as a Windows path with a space" env LAB_HOME="$(cygpath -w "$TMP_ROOT/win path")" "$BASH" "$LAB" play
  [ -d "$TMP_ROOT/win path/playground/.git" ] && pass "Windows-path LAB_HOME builds in the right folder" || fail "Windows-path LAB_HOME went somewhere else"
fi
if [ -d "$LAB_HOME/escape-room" ]; then
  echo mine > "$LAB_HOME/escape-room/room-3.notes"
  "$BASH" "$LAB" escape-room --room 3 >/dev/null 2>&1
  [ -f "$LAB_HOME/escape-room/room-3.notes" ] && pass "--room 3 leaves files it didn't make" || fail "--room 3 deleted room-3.notes"
fi

# a failing command inside a setup script must fail the build, not print "Ready"
mkdir -p "$TMP_ROOT/broken-kit"
cp -R "$KIT/lab" "$KIT/lib" "$KIT/labs" "$KIT/VERSION" "$KIT/labs.txt" "$TMP_ROOT/broken-kit/"
echo 'commit() { false; }' >> "$TMP_ROOT/broken-kit/labs/reviewable/setup.sh"
expect_code 2 "a failing setup command fails the build" env LAB_HOME="$TMP_ROOT/broken-home" "$BASH" "$TMP_ROOT/broken-kit/lab" reviewable

# a global gitignore (via XDG) must not change what the labs commit
mkdir -p "$TMP_ROOT/xdg/git"
printf '*.sh\n*.md\n' > "$TMP_ROOT/xdg/git/ignore"
h_plain="$(LAB_HOME="$TMP_ROOT/xdg-a" "$BASH" "$LAB" reviewable >/dev/null 2>&1; git -C "$TMP_ROOT/xdg-a/reviewable" rev-parse discounts)"
h_xdg="$(XDG_CONFIG_HOME="$TMP_ROOT/xdg" LAB_HOME="$TMP_ROOT/xdg-b" "$BASH" "$LAB" reviewable >/dev/null 2>&1; git -C "$TMP_ROOT/xdg-b/reviewable" rev-parse discounts)"
[ -n "$h_plain" ] && [ "$h_plain" = "$h_xdg" ] && pass "a global gitignore doesn't change the lab" || fail "global gitignore changed the lab ($h_plain vs $h_xdg)"

# ---------------------------------------------------------------- same hashes on every OS
if [ "${UPDATE_GOLDEN:-}" = 1 ]; then
  sort "$TMP_ROOT/refs.txt" > "$KIT/tests/expected-refs.txt"; echo "wrote tests/expected-refs.txt"
elif [ -f "$KIT/tests/expected-refs.txt" ]; then
  sort "$TMP_ROOT/refs.txt" > "$TMP_ROOT/refs.sorted"
  cp "$KIT/tests/expected-refs.txt" "$TMP_ROOT/expected"
  for s in $SKIPPED_WS; do grep -v "^${s}[/ ]" "$TMP_ROOT/expected" > "$TMP_ROOT/expected.new"; mv "$TMP_ROOT/expected.new" "$TMP_ROOT/expected"; done
  if diff "$TMP_ROOT/expected" "$TMP_ROOT/refs.sorted" >"$TMP_ROOT/out" 2>&1; then pass "commit hashes match tests/expected-refs.txt"
  else fail "commit hashes differ from tests/expected-refs.txt"; sed 's/^/      /' "$TMP_ROOT/out"; fi
else
  echo "skip  no tests/expected-refs.txt (create it with UPDATE_GOLDEN=1)"
fi

# ---------------------------------------------------------------- repo hygiene
if git -C "$KIT" ls-files -s lab 2>/dev/null | grep -q '^100755'; then pass "lab is committed as executable"
elif git -C "$KIT" ls-files --error-unmatch lab >/dev/null 2>&1; then fail "lab is not committed as executable (git update-index --chmod=+x lab)"
else echo "skip  lab not committed yet"; fi
expect_ok "try/README.md matches try/parts (bash tests/build-try-readme.sh)" "$BASH" "$KIT/tests/build-try-readme.sh" --check
crlf="$(cd "$KIT" && grep -rlI "$(printf '\r')" lab lib labs try tests 2>/dev/null || true)"
[ -z "$crlf" ] && pass "no CRLF in scripts" || fail "CRLF line endings in: $crlf"

AFTER="$(global_config_hash)"
[ "$BEFORE" = "$AFTER" ] && pass "your global Git config is unchanged" || fail "global Git config changed"

echo
if [ "$FAILED" -eq 0 ]; then echo "All tests passed."; else echo "Some tests FAILED."; fi
exit "$FAILED"
