# Lab: Escape room (Undo almost anything).
# Six independent rooms, each its own repo (room-1 ... room-6). Any order.
# Rebuild one room with: bash lab escape-room --room <n>

LAB_STEPS=1
LAB_ROOMS=6

remember() { # remember <key> <value>: answers the check needs, kept inside .git
  echo "$1=$2" >> .git/lab-room
}

room_start() { # room_start <n>: new repo with a README and notes
  reset_clock
  new_repo "room-$1"
  cd "room-$1" || exit 2
  put README.md <<'EOF'
# Shop

A tiny shop for the Git like a pro labs.
EOF
  put notes.txt <<'EOF'
Shop notes
EOF
  commit "Start the shop"
  echo "Open Monday to Friday." >> notes.txt
  commit "Add opening days"
}

# Room 1: reset too far, then kept working.
room_1() {
  room_start 1
  put giftcards.txt <<'EOF'
Gift cards: 25, 50 or 100.
EOF
  commit "Add gift cards"
  echo "Check a card's balance at the till." >> giftcards.txt
  commit "Check gift card balances"
  echo "Gift cards are shown on the receipt." >> giftcards.txt
  commit "Show gift cards on the receipt"
  tick
  git reset -q --hard HEAD~3
  echo "Open on Saturdays in December." >> notes.txt
  commit "Open on Saturdays in December"
}

# Room 2: deleted an unmerged branch.
room_2() {
  room_start 2
  git switch -q -c search
  put search.txt <<'EOF'
Search by product name.
EOF
  commit "Add product search"
  echo "Rank results by how often they're bought." >> search.txt
  commit "Rank search results"
  remember search "$(git rev-parse HEAD)"
  git switch -q main
  echo "Closed on public holidays." >> notes.txt
  commit "Note public holidays"
  git branch -q -D search
}

# Room 3: a rebase that threw away the teammate's change.
room_3() {
  room_start 3
  put prices.txt <<'EOF'
Coffee: 3.00
Tea: 2.50
EOF
  commit "Add prices"
  git switch -q -c menu
  put prices.txt <<'EOF'
Coffee: 3.00, oat milk +0.50
Tea: 2.50
EOF
  commit "Offer oat milk"
  echo "Cake: 4.00" >> prices.txt
  commit "Add cake"
  remember menu "$(git rev-parse HEAD)"
  git switch -q main
  as_teammate
  put prices.txt <<'EOF'
Coffee: 3.20
Tea: 2.50
EOF
  commit "Raise the price of coffee"
  as_author
  git switch -q menu
  tick
  if git rebase main >/dev/null 2>&1; then echo "room 3 should conflict" >&2; return 1; fi
  git checkout -q --theirs prices.txt # takes the branch's version: the coffee price rise is lost
  git add prices.txt
  GIT_EDITOR=true git rebase --continue >/dev/null 2>&1
}

# Room 4: dropped a stash.
room_4() {
  room_start 4
  echo "Idea: let customers save their cart for later." >> notes.txt
  tick
  git stash -q
  git stash drop -q
}

# Room 5: a bad merge that's already pushed.
room_5() {
  room_start 5
  put price.sh <<'EOF'
TAX_PERCENT=8
total() { echo $(( $1 + $1 * TAX_PERCENT / 100 )); }
EOF
  put test.sh <<'EOF'
#!/usr/bin/env bash
cd "$(dirname "$0")" || exit 2
. ./price.sh
if [ "$(total 1000)" = 1080 ]; then echo "All tests passed."; else echo "FAIL: total 1000 is $(total 1000), expected 1080"; exit 1; fi
EOF
  commit "Add prices and a test"
  git switch -q -c tax-change
  put price.sh <<'EOF'
TAX_PERCENT=80
total() { echo $(( $1 + $1 * TAX_PERCENT / 100 )); }
EOF
  commit "Update tax"
  echo "Tax rules reviewed in January." >> notes.txt
  commit "Note the tax review"
  git switch -q main
  tick
  git merge -q --no-ff -m "Merge branch 'tax-change'" tax-change
  remember merge "$(git rev-parse HEAD)"
  git init -q --bare -b main ../room-5.origin.git
  git remote add origin ../room-5.origin.git
  git push -q -u origin main 2>/dev/null
  git branch -q -D tax-change
}

# Room 6: two commits made on main that belong on a feature branch.
room_6() {
  room_start 6
  remember base "$(git rev-parse HEAD)"
  put logo.txt <<'EOF'
Print the shop logo at the top of every receipt.
EOF
  commit "Add a logo to receipts"
  echo "Logo is black and white so it prints on any printer." >> logo.txt
  commit "Use a black and white logo"
}

build_room() { "room_$1"; }

build_step() {
  local n=1
  while [ "$n" -le "$LAB_ROOMS" ]; do
    ( build_room "$n" ) # runs under errexit (run_build), so a failing room stops the build
    n=$((n + 1))
  done
}
