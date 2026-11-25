# Test fixture for the escape room: one way out of each room. Not a walkthrough for attendees.
# Runs from the escape-room workspace folder.

reflog_hash() { # reflog_hash <subject>: newest HEAD reflog entry "commit: <subject>"
  git log -g --format='%H %gs' HEAD | awk -v s="commit: $1" '{ h = $1; sub(/^[^ ]+ /, ""); if ($0 == s) { print h; exit } }'
}

solve_room_1() (
  cd room-1 || exit 1
  git cherry-pick "$(reflog_hash 'Add gift cards')^..$(reflog_hash 'Show gift cards on the receipt')"
)

solve_room_2() (
  cd room-2 || exit 1
  git branch search "$(reflog_hash 'Rank search results')"
)

solve_room_3() (
  cd room-3 || exit 1
  git reset -q --hard ORIG_HEAD
)

solve_room_4() (
  cd room-4 || exit 1
  git stash apply -q "$(git fsck --no-reflogs 2>/dev/null | awk '/dangling commit/ { print $3; exit }')"
)

solve_room_5() (
  cd room-5 || exit 1
  git revert -m 1 --no-edit "$(git rev-parse HEAD)" >/dev/null
  bash test.sh >/dev/null
  git push -q origin main 2>/dev/null
)

solve_room_6() (
  cd room-6 || exit 1
  git branch receipt-logo
  git reset -q --hard HEAD~2
)

solve_room() { "solve_room_$1"; }

solve_from() { # every room
  local n
  for n in 1 2 3 4 5 6; do solve_room "$n" || return 1; done
}
