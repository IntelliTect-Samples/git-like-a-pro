# Test fixture for the reviewable lab: solves it from a given step, the way a person
# would, but with the todo lists written by script. Not a walkthrough for attendees.

todo_editor() { # todo_editor <file>: use <file> as the rebase todo list
  export GIT_SEQUENCE_EDITOR="cp '$1'"
}

hash_of() { # hash_of <subject>: the commit on main..discounts with exactly this subject
  git log --format='%h %s' main..discounts | awk -v s="$1" '{ h = $1; sub(/^[^ ]+ /, ""); if ($0 == s) print h }'
}

solve_step1() {
  local todo
  todo="$(mktemp)"
  {
    echo "pick $(hash_of 'wip discounts')"
    echo "fixup $(hash_of 'more codes + tests')"
    echo "fixup $(hash_of 'fix typo')"
    echo "exec git commit -q --amend -m 'Add discount codes SAVE10 and SAVE25'"
    echo "pick $(hash_of 'apply discount')"
    echo "fixup $(hash_of 'fix test')"
    echo "exec git commit -q --amend -m 'Apply a discount code before tax'"
    echo "drop $(hash_of 'debug')"
    echo "drop $(hash_of 'remove debug')"
    echo "pick $(hash_of 'receipt and docs')"
    echo "fixup $(hash_of 'wip')"
    echo "fixup $(hash_of 'typo')"
    echo "exec git commit -q --amend -m 'Show discounts on the receipt and document them'"
  } > "$todo"
  todo_editor "$todo"
  git rebase -q -i main
  rm -f "$todo"
}

solve_step2() {
  local todo
  todo="$(mktemp)"
  {
    echo "pick $(hash_of 'Add discount codes SAVE10 and SAVE25')"
    echo "pick $(hash_of 'Apply a discount code before tax')"
    echo "pick $(hash_of 'Show discounts on the receipt and document them')"
    echo "exec git reset -q HEAD~ && git add src/receipt.sh tests/receipt.sh && git commit -q -m 'Show the discount on the receipt' && git add README.md && git commit -q -m 'Document discount codes'"
  } > "$todo"
  todo_editor "$todo"
  git rebase -q -i main
  rm -f "$todo"
}

solve_step3() {
  local first
  first="$(git rev-list --reverse main..discounts | head -n 1)"
  discounts_any_case # same fix the README describes
  git commit -q -a --fixup="$first"
  GIT_SEQUENCE_EDITOR=true git rebase -q -i --autosquash main
}

solve_step4() {
  git rebase -q --exec "bash test.sh" main >/dev/null
}

solve_from() { # solve_from <step>
  local s
  for s in 1 2 3 4; do
    [ "$s" -ge "$1" ] && "solve_step$s"
  done
  return 0
}
