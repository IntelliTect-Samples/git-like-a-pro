# Shared helpers for the lab tool. Sourced by ./lab; needs KIT set.
# Portable: bash 3.2 (macOS), Git Bash on Windows, Linux. No GNU-only tools.
# Exit codes: 0 ok, 1 something the user can fix in the command, 2 environment problem.

KIT_VERSION="$(cat "$KIT/VERSION")"
MARKER=".git-lab-workspace"
MIN_GIT_MAJOR=2
MIN_GIT_MINOR=40

die() { # die <code> <message>
  echo "lab: $2" >&2
  exit "$1"
}

native_path() { # show a path the way the user's shell writes it
  if command -v cygpath >/dev/null 2>&1; then cygpath -w "$1"; else echo "$1"; fi
}

is_windows() {
  case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) return 0 ;; *) return 1 ;; esac
}

abs_path() { # abs_path <path>: absolute, symlinks resolved when the folder exists (no GNU readlink)
  local p="$1"
  # A literal ~ (for example LAB_HOME="~/labs" in quotes) is expanded here on purpose.
  # shellcheck disable=SC2088
  case "$p" in "~") p="$HOME" ;; "~/"*) p="$HOME/${p#\~/}" ;; esac
  if is_windows && command -v cygpath >/dev/null 2>&1; then p="$(cygpath -u "$p")"; fi
  case "$p" in /*) ;; *) p="$PWD/$p" ;; esac
  if [ -d "$p" ]; then (cd -P "$p" && pwd); else echo "$p"; fi
}

lab_root() { # where workspaces live: $LAB_HOME, C:\git-labs on Windows, else ~/git-labs. Never creates it.
  if [ -n "${LAB_HOME:-}" ]; then abs_path "$LAB_HOME"; return; fi
  if is_windows && { { [ -d /c/git-labs ] && [ -w /c/git-labs ]; } || { [ ! -e /c/git-labs ] && [ -w /c ]; }; }; then
    echo /c/git-labs
  else
    abs_path "$HOME/git-labs"
  fi
}

git_version_ok() { # git_version_ok <"2.40.1 (Apple Git-x)">
  local v="$1" major rest minor
  major="${v%%.*}"; rest="${v#*.}"; minor="${rest%%.*}"
  case "$major$minor" in *[!0-9]*|"") return 1 ;; esac
  [ "$major" -gt "$MIN_GIT_MAJOR" ] && return 0
  [ "$major" -eq "$MIN_GIT_MAJOR" ] && [ "$minor" -ge "$MIN_GIT_MINOR" ]
}

require_git() {
  command -v git >/dev/null 2>&1 || die 2 "Git isn't installed (or isn't on your PATH). Run: bash lab doctor"
  local v
  v="$(git --version)"; v="${v#git version }"
  git_version_ok "$v" || die 2 "This course needs Git $MIN_GIT_MAJOR.$MIN_GIT_MINOR or newer; you have $v. Run: bash lab doctor"
}

# ---------------------------------------------------------------- registry

list_items() { # print labs.txt grouped by section, marking what isn't built yet
  local kind slug section minutes tier goal last="" where state
  while IFS='|' read -r kind slug section minutes tier goal; do
    case "$kind" in ""|\#*) continue ;; esac
    [ "$slug" = playground ] && continue
    if [ "$section" != "$last" ]; then echo; echo "$section"; last="$section"; fi
    if [ "$kind" = lab ]; then where="labs/$slug/setup.sh"; state="bash lab $slug"
    else where="try/$slug.sh"; state="bash lab try $slug"; fi
    [ -f "$KIT/$where" ] || state="(coming soon)"
    printf '  %-4s %-20s %3s min  %-8s %s\n' "$kind" "$slug" "$minutes" "$tier" "$goal"
    printf '       %s\n' "$state"
  done < "$KIT/labs.txt"
  echo
}

# ---------------------------------------------------------------- workspaces

reset_workspace() { # reset_workspace <name>: wipe and recreate one workspace, set WS
  local name="$1" root dir home kit trash
  case "$name" in ""|.|..|*[!A-Za-z0-9._-]*) die 1 "bad workspace name '$name'" ;; esac
  root="$(lab_root)"
  [ -n "$root" ] || die 2 "no workspace folder (set LAB_HOME)"
  mkdir -p "$root" 2>/dev/null || die 2 "can't create $(native_path "$root") (set LAB_HOME to a folder you can write to)"
  root="$(cd -P "$root" && pwd)"
  sweep_trash "$root"
  home="$(abs_path "$HOME")"
  case "$root" in /|"$home"|/[A-Za-z]) die 2 "refusing to use $(native_path "$root") itself as the workspace folder; set LAB_HOME to a subfolder" ;; esac
  dir="$root/$name"
  [ -L "$dir" ] && die 2 "refusing: $(native_path "$dir") is a symbolic link"
  kit="$(cd -P "$KIT" && pwd)"
  case "$kit/" in "$dir/"*) die 2 "refusing: the course kit is inside $(native_path "$dir")" ;; esac
  case "$(pwd -P)/" in
    "$dir/"*) die 1 "You're inside $(native_path "$dir"). Change to another folder first (for example: cd ~), then run the command again." ;;
  esac
  if [ -e "$dir" ]; then
    [ -f "$dir/$MARKER" ] || die 2 "refusing to delete $(native_path "$dir"): it wasn't made by this kit (no $MARKER file inside). If it's an old lab folder you cleaned out, delete it yourself, then run the command again."
    # Rename first: on Windows a folder open in another terminal can't be renamed, so we stop cleanly
    # instead of deleting half of it.
    trash="$root/.trash-$name-$$"
    mv "$dir" "$trash" 2>/dev/null || die 2 "couldn't replace $(native_path "$dir"). Is it open in another terminal or in VS Code? Close it (or cd out of it) and try again."
    chmod -R u+w "${trash:?}" 2>/dev/null || true
    rm -rf "${trash:?}" 2>/dev/null || echo "lab: note: couldn't fully delete $(native_path "$trash"); delete it later." >&2
  fi
  mkdir -p "$dir"
  printf 'kit %s\nworkspace %s\n' "$KIT_VERSION" "$name" > "$dir/$MARKER"
  WS="$dir"
}

workspace_dir() { # workspace_dir <name>: path of an existing workspace, or die
  local dir
  dir="$(lab_root)/$1"
  [ -f "$dir/$MARKER" ] || die 1 "There's no '$1' workspace yet. Build it first: bash lab $1"
  echo "$dir"
}

user_editor() { # prints "code --wait" when the user has no Git editor and VS Code is installed
  if [ -n "${GIT_EDITOR:-}${VISUAL:-}${EDITOR:-}" ] || git config --get core.editor >/dev/null 2>&1; then
    return 0
  fi
  if command -v code >/dev/null 2>&1; then echo "code --wait"; fi
}

finish_repos() { # finish_repos <editor>: per-repo settings so people's own config can't change a lab
  local editor="$1" d
  for d in "$WS" "$WS"/*; do
    [ -d "$d/.git" ] || continue
    git -C "$d" config core.autocrlf false
    git -C "$d" config commit.gpgsign false
    git -C "$d" config tag.gpgsign false
    git -C "$d" config core.hooksPath .git/hooks
    git -C "$d" config rerere.enabled false
    git -C "$d" config pull.rebase false
    git -C "$d" config alias.lg "log --graph --oneline --decorate"
    if [ -n "$editor" ]; then git -C "$d" config core.editor "$editor"; fi
    if ! grep -qx "$MARKER" "$d/.git/info/exclude" 2>/dev/null; then echo "$MARKER" >> "$d/.git/info/exclude"; fi
  done
}

# ---------------------------------------------------------------- deterministic builders
# Used inside setup scripts. Run in a subshell after begin_build.

begin_build() {
  # Ignore the user's global and system config, global gitignore/attributes (XDG) and config set
  # through the environment, so every machine builds the same commits.
  export GIT_CONFIG_GLOBAL="$KIT/lib/empty.gitconfig"
  export GIT_CONFIG_NOSYSTEM=1
  export XDG_CONFIG_HOME="$KIT/lib/no-xdg"
  unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_EDITOR GIT_SEQUENCE_EDITOR GIT_COMMON_DIR
  unset GIT_CONFIG_PARAMETERS GIT_TEMPLATE_DIR GIT_ATTR_SOURCE GIT_CONFIG GIT_DEFAULT_HASH
  unset GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_NAMESPACE GIT_CEILING_DIRECTORIES
  # The only setting we pass in: trust the workspace even if another user created the folder
  # (an admin-made C:\git-labs, a shared drive), which the user's own global config might allow.
  export GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=safe.directory GIT_CONFIG_VALUE_0='*'
  as_author
  reset_clock
}

reset_clock() { # back to the fixed start time (rooms call this so each builds the same alone or together)
  LAB_CLOCK=1767225600 # 2026-01-01 00:00 UTC
  tick
}

as_author() {
  export GIT_AUTHOR_NAME="Sam Developer" GIT_AUTHOR_EMAIL="sam@example.com"
  export GIT_COMMITTER_NAME="Sam Developer" GIT_COMMITTER_EMAIL="sam@example.com"
}

as_teammate() {
  export GIT_AUTHOR_NAME="Alex Teammate" GIT_AUTHOR_EMAIL="alex@example.com"
  export GIT_COMMITTER_NAME="Alex Teammate" GIT_COMMITTER_EMAIL="alex@example.com"
}

tick() { # advance the fixed clock one hour, so every commit has a known date
  LAB_CLOCK=$((LAB_CLOCK + 3600))
  export GIT_AUTHOR_DATE="$LAB_CLOCK +0000" GIT_COMMITTER_DATE="$LAB_CLOCK +0000"
}

new_repo() { # new_repo <dir>: empty repo on main; the kit's marker is ignored from the start
  mkdir -p "$1"
  git -C "$1" init -q -b main
  git -C "$1" config core.autocrlf false
  echo "$MARKER" >> "$1/.git/info/exclude"
}

put() { # put <file>: write stdin to file (LF line endings, folders created)
  mkdir -p "$(dirname "$1")"
  cat > "$1"
}

commit() { # commit <message>: stage everything and commit at the next clock tick (new_repo ignores the marker)
  git add -A
  tick
  git commit -q -m "$1"
}

# ---------------------------------------------------------------- commands

print_ready() { # print_ready <what> <readme> [step]
  echo
  echo "Ready: $1"
  echo "  Folder:  $(native_path "$WS")"
  echo "  Go there: cd \"$(native_path "$WS")\""
  if [ -n "${3:-}" ] && [ "$3" != 1 ]; then echo "  Starting at step $3."; fi
  echo "  Instructions: $(native_path "$2")"
}

run_build() { # run_build <what> <function> [args...]: run a builder with errexit on, in a subshell; die if any command fails
  local what="$1" rc had_e=0
  shift
  case "$-" in *e*) had_e=1 ;; esac
  set +e
  ( set -e; "$@" )
  rc=$?
  [ "$had_e" -eq 1 ] && set -e
  [ "$rc" -eq 0 ] || die 2 "building $what failed (please tell the instructor)"
}

_build_lab_body()  { . "$1"; begin_build; cd "$2" || exit 2; build_step "$3"; }  # <setup> <dir> <step>
_build_room_body() { . "$1"; begin_build; cd "$2" || exit 2; build_room "$3"; }  # <setup> <dir> <room>
_build_try_body()  { . "$1"; begin_build; cd "$2" || exit 2; build; }             # <script> <dir>

sweep_trash() { # sweep_trash <dir>: best effort, remove .trash-* folders an earlier run couldn't delete
  local t
  for t in "$1"/.trash-*; do
    [ -d "$t" ] || continue
    chmod -R u+w "$t" 2>/dev/null || true
    rm -rf "${t:?}" 2>/dev/null || true
  done
}

build_lab() { # build_lab <slug> <step>
  local slug="$1" step="$2" setup="$KIT/labs/$1/setup.sh" steps editor
  steps="$( . "$setup"; echo "$LAB_STEPS" )"
  case "$step" in ""|*[!0-9]*) die 1 "--step needs a number from 1 to $steps" ;; esac
  step=$((10#$step)) # "02" -> 2
  { [ "$step" -ge 1 ] && [ "$step" -le "$steps" ]; } || die 1 "$slug has steps 1 to $steps"
  case " $( . "$setup"; echo "${LAB_NEEDS:-}" ) " in
    *" git-lfs "*) git lfs version >/dev/null 2>&1 || die 2 "The $slug lab needs git-lfs. Install it (macOS: brew install git-lfs; Linux: your package manager), run: git lfs install, then try again." ;;
  esac
  editor="$(user_editor)"
  reset_workspace "$slug"
  run_build "$slug" _build_lab_body "$setup" "$WS" "$step"
  finish_repos "$editor"
  print_ready "lab $slug" "$KIT/labs/$slug/README.md" "$step"
}

build_one_room() { # build_one_room <slug> <room>: rebuild one room of an existing room lab
  local slug="$1" room="$2" setup="$KIT/labs/$1/setup.sh" rooms dir editor
  rooms="$( . "$setup"; echo "${LAB_ROOMS:-}" )"
  [ -n "$rooms" ] || die 1 "$slug has no rooms; use --step instead"
  case "$room" in ""|*[!0-9]*) die 1 "--room needs a number from 1 to $rooms" ;; esac
  room=$((10#$room)) # "03" -> 3
  { [ "$room" -ge 1 ] && [ "$room" -le "$rooms" ]; } || die 1 "$slug has rooms 1 to $rooms"
  [ -f "$(lab_root)/$slug/$MARKER" ] || { build_lab "$slug" 1; return; }
  dir="$(workspace_dir "$slug")"
  dir="$(cd -P "$dir" && pwd)"
  case "$(pwd -P)/" in
    "$dir/room-$room/"*|"$dir/room-$room.origin.git/"*) die 1 "You're inside room $room. Change to another folder first (for example: cd ..), then run the command again." ;;
  esac
  editor="$(user_editor)"
  sweep_trash "$dir"
  # Only the room's own folders: room-N and (room 5) its remote room-N.origin.git.
  local p trash
  for p in "room-$room" "room-$room.origin.git"; do
    [ -e "$dir/$p" ] || continue
    trash="$dir/.trash-$p-$$"
    mv "$dir/$p" "$trash" 2>/dev/null || die 2 "couldn't replace room $room. Is it open in another terminal or in VS Code? Close it (or cd out of it) and try again."
    chmod -R u+w "${trash:?}" 2>/dev/null || true
    rm -rf "${trash:?}" 2>/dev/null || echo "lab: note: couldn't fully delete $(native_path "$trash"); delete it later." >&2
  done
  run_build "room $room" _build_room_body "$setup" "$dir" "$room"
  WS="$dir"
  finish_repos "$editor"
  echo
  echo "Room $room rebuilt: $(native_path "$dir/room-$room")"
  echo "  Go there: cd \"$(native_path "$dir/room-$room")\""
}

build_try() { # build_try <name>
  local name="$1" script="$KIT/try/$1.sh" editor
  case "$name" in ""|*[!A-Za-z0-9-]*) die 1 "bad Try-it name '$name'" ;; esac
  [ -f "$script" ] || die 1 "No Try-it called '$name'. Run: bash lab list"
  editor="$(user_editor)"
  if [ "$name" = playground ]; then reset_workspace playground; else reset_workspace "try-$name"; fi
  run_build "$name" _build_try_body "$script" "$WS"
  finish_repos "$editor"
  print_ready "$name" "$KIT/try/README.md"
}

GOALS_MET=0
GOALS_TOTAL=0
goal() { # goal <description> <command...>: one line of a lab check
  local text="$1"; shift
  GOALS_TOTAL=$((GOALS_TOTAL + 1))
  if "$@" >/dev/null 2>&1; then
    GOALS_MET=$((GOALS_MET + 1)); echo "  [done]     $text"
  else
    echo "  [not yet]  $text"
  fi
}

check_lab() { # check_lab <slug>
  local slug="$1" dir
  [ -f "$KIT/labs/$slug/check.sh" ] || die 1 "Lab '$slug' has no automatic check; use its README."
  dir="$(workspace_dir "$slug")"
  echo "Checking $slug in $(native_path "$dir")"
  ( . "$KIT/labs/$slug/check.sh"; cd "$dir" || exit 2; run_checks
    echo
    echo "$GOALS_MET of $GOALS_TOTAL goals met."
    [ "$GOALS_MET" -eq "$GOALS_TOTAL" ] )
}

show_hint() { # show_hint <slug> [step]: print one "## Step N" section of HINTS.md
  local file="$KIT/labs/$1/HINTS.md"
  [ -f "$file" ] || die 1 "No hints for '$1'. Run: bash lab list"
  if [ -z "$2" ]; then
    echo "Hints for $1 (show one with: bash lab hint $1 <number>):"
    grep -E '^## (Step|Room) ' "$file" | sed 's/^## /  /'
    return 0
  fi
  case "$2" in *[!0-9]*) die 1 "the hint number must be a number" ;; esac
  local text
  text="$(awk -v want="$2" '
    /^## / { on = 0 }
    /^## (Step|Room) / { split($3, a, /[^0-9]/); on = (a[1] == want) }
    on { print }
  ' "$file")"
  [ -n "$text" ] || die 1 "No hint number $2."
  echo "$text"
}

open_workspace() { # open_workspace <name>
  local dir
  dir="$(workspace_dir "$1")"
  if command -v code >/dev/null 2>&1; then code "$dir"; else echo "VS Code's 'code' command isn't available. Folder: $(native_path "$dir")"; fi
}
