# Hints: Make it reviewable

Show one with `bash lab hint reviewable <step>`.

## Step 1 - Squash the noise

- In the todo list, the top line is the oldest commit. Keep `pick` on the first commit of each group and change the others to `fixup` (or `f`), which keeps the code and throws away the message.
- Lines can be moved: put `fix test` right under `apply discount` so it joins that commit.
- `debug` and `remove debug` cancel out: change both to `drop` (or `d`). Drop only `debug` and the rebase stops on `remove debug` as an empty commit; drop only `remove debug` and the debug line stays in your history. Either way: `git rebase --abort` (or `git reset --hard ORIG_HEAD` once it's finished), then drop both.
- The three groups, oldest first: `wip discounts` + `more codes + tests` + `fix typo`; then `apply discount` + `fix test`; then `receipt and docs` + `wip` + `typo`.
- To fix messages, use `reword` (or `r`) instead of `pick`, or run `git commit --amend` afterwards for the last one.
- Something went wrong? `git rebase --abort` puts everything back. After a finished rebase, `git reset --hard ORIG_HEAD` does.

## Step 2 - Split the mixed commit

- In `git rebase -i main`, change `pick` to `edit` on the receipt-and-docs commit. Git stops right after applying it.
- `git reset HEAD~` undoes that commit but keeps its changes in your working folder. `tests/receipt.sh` is a new file, so it now shows as untracked (`??`), and `git commit -a` would leave it out: add it by name.
- Then `git add src/receipt.sh tests/receipt.sh`, commit, `git add README.md`, commit, and `git rebase --continue`.

## Step 3 - Squash in a review fix

- Find the hash with `git log --oneline main..discounts`; the first commit is at the bottom.
- `git commit -a --fixup=<hash>` makes a commit titled `fixup! Add discount codes ...`.
- `git rebase -i --autosquash main` opens the todo list with that commit already moved under its target and marked `fixup`. Save and close.
- Tip: `git config --global rebase.autoSquash true` makes every `rebase -i` do this.

## Step 4 - Prove every commit passes

- If the rebase stops with a failing test, you're on the commit that fails. Fix it, `git commit --amend -a --no-edit`, then `git rebase --continue`.
- `--exec` works with any command, such as your real build: `git rebase --exec "dotnet test" main`.
