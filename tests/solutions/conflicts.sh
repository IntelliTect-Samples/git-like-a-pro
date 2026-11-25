# Test fixture for the conflicts lab: resolves the conflicts by writing the
# finished files, as a person would. Not a walkthrough for attendees.

continue_rebase() { GIT_EDITOR=true git rebase --continue >/dev/null 2>&1; }

solve_step1() {
  git switch -q loyalty
  git rebase main >/dev/null 2>&1 && return 1 # must conflict
  price_resolved
  receipt_loyalty
  git add -A
  continue_rebase && return 1                 # the README conflicts next
  readme rounding loyalty
  git add -A
  continue_rebase
}

solve_step2() {
  git switch -q main
  git merge -q --no-ff --no-edit loyalty
}

solve_step3() {
  git switch -q main
  git merge --ff-only receipt-footer >/dev/null 2>&1 && return 1 # must refuse
  git switch -q receipt-footer
  git rebase main >/dev/null 2>&1 && return 1                    # must conflict
  receipt_resolved
  git add -A
  continue_rebase
  git switch -q main
  git merge -q --ff-only receipt-footer
}

solve_from() { # solve_from <step>
  local s
  for s in 1 2 3; do
    if [ "$s" -ge "$1" ]; then "solve_step$s" || return 1; fi
  done
}
