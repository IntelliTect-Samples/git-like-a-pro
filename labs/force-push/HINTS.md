# Hints: Force push safely

Show one with `bash lab hint force-push <step>`.

## Step 1 - main moved under your pull request

- After the rebase, your commits are new commits with new hashes. `origin/receipt-totals` still points at the old ones, so a normal push would throw them away, and Git refuses.
- `git push --force-with-lease` compares the server's branch with your `origin/receipt-totals`. Nobody else pushed, so they match and the push goes through.
- Stuck in the rebase? `git status` tells you what to do, and `git rebase --abort` starts over.

## Step 2 - Alex pushed to your branch

- "stale info" means the server's branch is no longer where your `origin/receipt-totals` says it is. Someone pushed, and nothing was overwritten. That's good.
- Did you push with a plain `--force-with-lease` after `git fetch` and lose Alex's commit? It's still in `../alex`. Look at it first with `git -C ../alex lg --all`, then rebuild with `bash lab force-push --step 2` and try again. Rebuilding recreates `alex/` too.
- `git pull --rebase` fetches and then replays your amended commit on top of Alex's commit (`receipt.txt`). Your earlier commits are already on the server, so only the amended commit gets replayed. It now holds just the README note, because its `receipt-notes.txt` part is already on the server and Git drops it. Running `git show --stat` before the pull still shows both files.
- After the pull your branch contains everything on the server, so a plain `git push` is a fast-forward.

## Step 3 - main is protected

- `origin/main~1:main` means "make main on the server point at the commit before its current tip". That's a history rewrite.
- `pre-receive hook declined` is how Git reports any server-side refusal. The server's reason is on the line starting with `remote:` above it.
