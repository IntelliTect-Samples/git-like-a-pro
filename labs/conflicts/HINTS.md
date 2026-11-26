# Hints: Conflicts

Show one with `bash lab hint conflicts <step>`.

## Step 1 - Rebase loyalty onto main

- During the rebase, the top half of a conflict (after `<<<<<<<`) is `main`, which already has the teammate's rounding. The bottom half (before `>>>>>>>`) is your `loyalty` commit.
- The finished `total` needs three things. Keep the `[member]` comment, the `if` line that takes 5% off, and the teammate's two lines that compute `tax` with rounding.
- For the README, keep both lines one after the other and delete the markers.
- `git diff` during a conflict shows what's still unresolved, and `bash test.sh` tells you whether both changes work.
- Does the merge editor say "No changes accepted"? Accept both sides, then fix up the result by hand.

## Step 2 - Merge loyalty with a merge commit

- Make sure you're on `main` first with `git switch main`.
- Git opens your editor for the merge message. Save and close it to finish, or add `--no-edit` to skip it.
- In `git lg`, the merge commit has two parents. One is `main` before the merge and the other is `loyalty`.

## Step 3 - Fast-forward receipt-footer

- `--ff-only` only moves `main` forward if `main` is already part of the branch's history. Rebasing makes that true.
- In `src/receipt.sh`, keep `echo "Total: $(total "$1" "${2:-}")"` from `main` and add the `echo "Thank you for shopping!"` line after it. Keep the `[member]` comment too.
- After `git rebase --continue`, run `git switch main` and try the `--ff-only` merge again.
