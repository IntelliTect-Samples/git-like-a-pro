# Try-it: spot a detached HEAD inside a submodule, with a commit that was never pushed.
# Built by: bash lab try submodule-trap
# lib.git and app.git are folder remotes; app/ is a clone where someone committed inside lib
# while it was detached, and didn't push it. app/ starts with lib showing "new commits".

TRY_DIRTY=1 # app/ starts with a moved submodule, on purpose

submodule_trap_file() { git -c protocol.file.allow=always "$@"; } # local submodules need file transport

build() {
  git init -q --bare -b main lib.git
  git init -q --bare -b main app.git

  new_repo work-lib
  cd work-lib || return 1
  put round.sh <<'EOF2'
round_cents() { echo $(( ($1 + 5) / 10 * 10 )); }
EOF2
  commit "Add round_cents"
  git remote add origin ../lib.git
  git push -q origin main
  cd ..

  new_repo work-app
  cd work-app || return 1
  git remote add origin ../app.git
  put README.md <<'EOF2'
# Shop app

Uses the lib submodule for rounding.
EOF2
  submodule_trap_file submodule add -q ../lib.git lib
  commit "Add the lib submodule"
  git push -q origin main
  cd ..
  rm -rf work-lib work-app

  # The clone the attendee looks at. Keep file transport allowed here so submodule commands work.
  submodule_trap_file clone -q --recurse-submodules app.git app
  git -C app config protocol.file.allow always
  cd app/lib || return 1
  git config core.autocrlf false
  echo 'round_dollars() { echo $(( ($1 + 50) / 100 * 100 )); }' >> round.sh
  commit "Add round_dollars"
}
