# Checks for the escape room. Each room is checked on its own result, not on how you got there.

answer() { # answer <room> <key>  (called from inside the room's folder)
  sed -n "s/^$2=//p" .git/lab-room 2>/dev/null
}

in_room() { # in_room <n> <command...>
  local n="$1"; shift
  [ -d "room-$n/.git" ] || return 1
  ( cd "room-$n" && "$@" )
}

idle() { [ ! -d .git/rebase-merge ] && [ ! -d .git/rebase-apply ] && [ ! -f .git/MERGE_HEAD ] && [ ! -f .git/CHERRY_PICK_HEAD ] && [ ! -f .git/REVERT_HEAD ]; }

has_subject() { git log --format=%s main | grep -qx "$1"; }

room1() {
  idle && has_subject "Add gift cards" && has_subject "Check gift card balances" &&
    has_subject "Show gift cards on the receipt" && has_subject "Open on Saturdays in December" &&
    git show main:giftcards.txt | grep -q "shown on the receipt"
}

room2() { [ "$(git rev-parse -q --verify search 2>/dev/null)" = "$(answer 2 search)" ]; }

room3() { idle && [ "$(git rev-parse -q --verify menu 2>/dev/null)" = "$(answer 3 menu)" ]; }

room4() { grep -q "save their cart" notes.txt || git show HEAD:notes.txt | grep -q "save their cart"; }

room5() {
  local merge
  merge="$(answer 5 merge)"
  idle && git merge-base --is-ancestor "$merge" main &&
    [ "$(git rev-parse main)" = "$(git -C ../room-5.origin.git rev-parse main)" ] &&
    git show main:price.sh | grep -q 'TAX_PERCENT=8$'
}

room5_no_tax_note() { ! git show main:notes.txt | grep -q "Tax rules reviewed"; }

room6() {
  local base
  base="$(answer 6 base)"
  [ "$(git rev-parse main)" = "$base" ] &&
    [ "$(git rev-list --count "$base..receipt-logo" 2>/dev/null)" -eq 2 ] &&
    git log --format=%s receipt-logo | grep -qx "Use a black and white logo"
}

run_checks() {
  goal "Room 1: main has the three gift card commits back, and the Saturday commit" in_room 1 room1
  goal "Room 2: the search branch is back, at its last commit" in_room 2 room2
  goal "Room 3: menu is back to how it was before the rebase" in_room 3 room3
  goal "Room 4: the cart idea from the dropped stash is back in notes.txt" in_room 4 room4
  goal "Room 5: a new commit on main fixes the tax, and it's pushed (merge kept in history)" in_room 5 room5
  goal "Room 5: the whole merge is undone, including the tax review note" in_room 5 room5_no_tax_note
  goal "Room 6: main is back where it was, and both logo commits are on receipt-logo" in_room 6 room6
}
