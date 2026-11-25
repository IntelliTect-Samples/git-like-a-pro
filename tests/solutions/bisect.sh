# Test fixture for the bisect lab. Not a walkthrough for attendees.

solve_step1() {
  local bad
  git bisect start main v1.0 >/dev/null
  git bisect run bash test.sh >/dev/null 2>&1
  bad="$(git rev-parse refs/bisect/bad)"
  git bisect reset >/dev/null 2>&1
  git tag first-bad "$bad"
}

solve_step2() {
  git revert --no-edit first-bad >/dev/null
}

solve_from() {
  if [ "$1" -le 1 ]; then solve_step1 || return 1; fi
  solve_step2
}
