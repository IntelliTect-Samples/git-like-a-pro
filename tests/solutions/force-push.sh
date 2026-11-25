# Test fixture for the force-push lab, including the pushes that must be refused.
# Not a walkthrough for attendees. Runs from the workspace folder.

solve_step1() (
  cd me || exit 1
  git fetch -q
  git rebase -q origin/main
  git push -q 2>/dev/null && exit 1                  # must be refused: not a fast-forward
  git push -q --force-with-lease
)

solve_step2() (
  cd me || exit 1
  bash ../teammate.sh >/dev/null
  echo "Totals include tax." >> README.md
  git commit -q -a --amend -m "Add receipt notes and explain the total"
  git push -q --force-with-lease 2>/dev/null && exit 1             # stale info
  git fetch -q
  git push -q --force-with-lease --force-if-includes 2>/dev/null && exit 1
  git pull -q --rebase
  git push -q
)

solve_step3() (
  cd me || exit 1
  git push -q --force origin origin/main~1:main 2>/dev/null && exit 1
  git push -q origin --delete main 2>/dev/null && exit 1
  exit 0
)

solve_from() {
  local s
  for s in 1 2 3; do
    if [ "$s" -ge "$1" ]; then "solve_step$s" || return 1; fi
  done
}
