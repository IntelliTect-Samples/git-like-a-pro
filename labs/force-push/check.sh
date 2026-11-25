# Checks for the force-push lab. Run from the workspace folder; looks at "Bitbucket" (bitbucket.git) and me/.

bb() { git -C bitbucket.git "$@"; }

on_latest_main() { bb merge-base --is-ancestor main receipt-totals; }

alex_kept() { bb log --format=%s receipt-totals | grep -qx "Show the payment method"; }

note_kept() { bb show receipt-totals:README.md | grep -q "Totals include tax."; }

own_commits_kept() {
  bb log --format=%s main..receipt-totals | grep -qx "Add the total line"
}

in_sync() { [ "$(git -C me rev-parse receipt-totals)" = "$(bb rev-parse receipt-totals)" ]; }

main_untouched() {
  [ "$(bb log -1 --format=%s main)" = "Thank customers in the README" ] && [ "$(bb rev-list --count main)" -eq 2 ]
}

idle() { [ ! -d me/.git/rebase-merge ] && [ ! -d me/.git/rebase-apply ] && [ ! -f me/.git/MERGE_HEAD ]; }

run_checks() {
  goal "No rebase or merge is still in progress in me/" idle
  goal "Step 1: receipt-totals on Bitbucket is rebased onto the latest main" on_latest_main
  goal "Step 1: your own commits are still on it" own_commits_kept
  goal "Step 2: Alex's commit is still on it (nobody's work was overwritten)" alex_kept
  goal "Step 2: your amended README note made it to Bitbucket" note_kept
  goal "Your local receipt-totals matches Bitbucket" in_sync
  goal "Step 3: main on Bitbucket is unchanged (the permission held)" main_untouched
}
