# Lab: Force push safely (Rebase workflows with Bitbucket).
# bitbucket.git stands in for Bitbucket: a bare repo whose pre-receive hook blocks force pushes
# and deletes on main, like a branch permission. me/ is your clone; alex/ is a teammate's clone,
# driven by ./teammate.sh.
# Steps: 1 main moved under your open PR, 2 your branch is rebased and pushed, 3 Alex's commit is
# integrated too (only the protected-main step is left).

LAB_STEPS=3

write_hook() {
  put bitbucket.git/hooks/pre-receive <<'EOF'
#!/bin/sh
# Stands in for a Bitbucket branch permission on main: no force pushes (history rewrites), no deletes.
zero=0000000000000000000000000000000000000000
while read -r old new ref; do
  [ "$ref" = refs/heads/main ] || continue
  if [ "$new" = "$zero" ]; then
    echo "Permission denied to delete branch main" >&2
    exit 1
  fi
  if [ "$old" != "$zero" ] && ! git merge-base --is-ancestor "$old" "$new"; then
    echo "Permission denied to force push branch main" >&2
    exit 1
  fi
done
exit 0
EOF
  chmod +x bitbucket.git/hooks/pre-receive
  git -C bitbucket.git config core.hooksPath hooks
}

write_teammate() {
  put teammate.sh <<'EOF'
#!/usr/bin/env bash
# Plays your teammate Alex: pushes a commit to your pull request branch on "Bitbucket".
# Run it from anywhere: bash teammate.sh
set -e
cd "$(dirname "$0")/alex"
export GIT_AUTHOR_NAME="Alex Teammate" GIT_AUTHOR_EMAIL="alex@example.com"
export GIT_COMMITTER_NAME="Alex Teammate" GIT_COMMITTER_EMAIL="alex@example.com"
export GIT_AUTHOR_DATE="1767484800 +0000" GIT_COMMITTER_DATE="1767484800 +0000"
git fetch -q origin
git switch -q -C receipt-totals origin/receipt-totals
echo "Payment: card" >> receipt.txt
git add receipt.txt
git commit -q -m "Show the payment method"
git push -q origin receipt-totals
echo "Alex pushed \"Show the payment method\" to receipt-totals."
EOF
}

build_base() {
  git init -q --bare -b main bitbucket.git
  write_hook
  write_teammate

  new_repo me
  cd me || exit 2
  put receipt.txt <<'EOF'
Subtotal: 10.00
Tax:       0.80
EOF
  put README.md <<'EOF'
# Receipts
EOF
  commit "Start the receipt"
  git remote add origin ../bitbucket.git
  git push -q -u origin main

  git switch -q -c receipt-totals
  echo "Total:    10.80" >> receipt.txt
  commit "Add the total line"
  put receipt-notes.txt <<'EOF'
Receipt notes
EOF
  commit "Add receipt notes"
  git push -q -u origin receipt-totals
  cd ..

  # Alex clones and moves main while your pull request is open.
  as_teammate
  git clone -q bitbucket.git alex
  cd alex || exit 2
  echo "Thank you for shopping!" >> README.md
  commit "Thank customers in the README"
  git push -q origin main
  cd ..
  as_author
}

step2_amend() { # what the README has you do at the start of step 2
  echo "Totals include tax." >> README.md
  tick
  git commit -q -a --amend -m "Add receipt notes and explain the total"
}

build_step() {
  build_base
  cd me || exit 2
  if [ "$1" -ge 2 ]; then # step 1 done: rebased onto the new main and force-pushed with a lease
    git fetch -q origin
    tick
    git rebase -q origin/main
    git push -q --force-with-lease origin receipt-totals
  fi
  if [ "$1" -ge 3 ]; then # step 2 done: Alex's commit kept, your amended commit replayed on top
    bash ../teammate.sh >/dev/null
    step2_amend
    git fetch -q origin
    tick
    git pull -q --rebase origin receipt-totals
    git push -q origin receipt-totals
  fi
  cd ..
}
