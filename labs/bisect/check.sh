# Checks for the bisect lab.

culprit() { sed -n 's/^culprit=//p' .git/lab-bisect; }

tag_on_culprit() { [ "$(git rev-parse -q --verify 'first-bad^{commit}' 2>/dev/null)" = "$(culprit)" ]; }

bisect_finished() { [ ! -f .git/BISECT_LOG ] && [ ! -f .git/BISECT_START ]; }

on_main() { [ "$(git symbolic-ref -q --short HEAD)" = main ]; }

history_kept() { git merge-base --is-ancestor "$(culprit)" main && main_passes; }

main_passes() {
  local tmp rc=1
  tmp="$(mktemp -d)"
  git archive main | tar -x -C "$tmp"
  bash "$tmp/test.sh" >/dev/null 2>&1 && rc=0
  rm -rf "${tmp:?}"
  return "$rc"
}

run_checks() {
  goal "The tag first-bad points at the commit that broke the tests" tag_on_culprit
  goal "Bisect is finished (git bisect reset)" bisect_finished
  goal "You're back on main" on_main
  goal "main passes the tests again" main_passes
  goal "...without rewriting history (the bad commit is still there, undone by a revert)" history_kept
}
