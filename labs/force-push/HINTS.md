# Hints: Force push safely

Show one with `bash lab hint force-push <step>`.

## Step 1 - main moved under your pull request

- After the rebase, your commits are new commits (new hashes). `origin/receipt-totals` still points at the old ones, so a normal push would throw them away: Git refuses.
- `git push --force-with-lease` compares the server's branch with your `origin/receipt-totals`. They match (nobody else pushed), so it goes through.
- Stuck in the rebase? `git status` says what to do; `git rebase --abort` starts over.

## Step 2 - Alex pushed to your branch

- "stale info" means: the server's branch is no longer where your `origin/receipt-totals` says it is. Someone pushed. Good: nothing was overwritten.
- Pushed with a plain `--force-with-lease` after `git fetch` and Alex's commit is gone? It's still in `../alex`: look first (`git -C ../alex lg --all`), then rebuild with `bash lab force-push --step 2` and try again (rebuilding recreates `alex/` too).
- `git pull --rebase` fetches, then replays your amended commit on top of Alex's commit. Alex's commit (`receipt.txt`) is now underneath and your earlier commits are already on the server, so only your amended commit is replayed, and it now holds just the README note.
- After the pull, your branch contains everything on the server, so a plain `git push` is a fast-forward.

## Step 3 - main is protected

- `origin/main~1:main` means "make main on the server point at the commit before its current tip": a history rewrite.
- `pre-receive hook declined` is how Git reports any server-side refusal. The line starting with `remote:` above it is the server's reason.
