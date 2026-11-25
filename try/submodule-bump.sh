# Try-it: clone with submodules, move one to a new version, commit the pointer, push both.
# Built by: bash lab try submodule-bump
# Two bare remotes: lib.git (a library with two versions) and app.git (uses lib as a submodule,
# pinned to the older version). The attendee clones app.git into app/.

submodule_bump_file() { git -c protocol.file.allow=always "$@"; } # local submodules need file transport

build() {
  git init -q --bare -b main lib.git
  git init -q --bare -b main app.git

  new_repo work-lib
  cd work-lib || return 1
  put round.sh <<'EOF2'
round_cents() { echo "$1"; }
EOF2
  commit "Add round_cents"
  git tag v1.0
  put round.sh <<'EOF2'
round_cents() { echo $(( ($1 + 5) / 10 * 10 )); }
EOF2
  commit "Round to the nearest 10 cents"
  git tag v1.1
  git remote add origin ../lib.git
  git push -q origin main v1.0 v1.1
  cd ..

  new_repo work-app
  cd work-app || return 1
  git remote add origin ../app.git
  put README.md <<'EOF2'
# Shop app

Uses the lib submodule for rounding.
EOF2
  submodule_bump_file submodule add -q ../lib.git lib
  git -C lib checkout -q v1.0
  commit "Add the lib submodule at v1.0"
  git push -q origin main
  cd ..

  rm -rf work-lib work-app
}
