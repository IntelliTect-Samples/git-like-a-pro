### worktree-hotfix

```
bash lab try worktree-hotfix
```

The repo is in `shop`. You're halfway through a change on `feature` when an urgent bug comes in. The tax rate on `main` is 80 instead of 8.

1. Look at your unfinished work:

   ```
   cd shop
   git status
   ```

   `src/receipt.sh` is modified and not committed. You don't need to stash or commit it.

2. Make a second working folder for the hotfix, on a new branch from `main`:

   ```
   git worktree add -b hotfix ../hotfix main
   ```

3. Fix the bug there and commit:

   ```
   cd ../hotfix
   echo "TAX_PERCENT=8" > src/tax.sh
   git commit -am "Fix the tax rate"
   ```

4. Go back. Your change is untouched, and the hotfix commit is already in this repo because worktrees share one `.git`:

   ```
   cd ../shop
   git status --short
   git worktree list
   git log --oneline -1 hotfix
   ```

5. Remove the extra folder when you're done. The `hotfix` branch stays:

   ```
   git worktree remove ../hotfix
   git branch
   ```

What happens if you try `git worktree add ../again feature`? Git refuses, because a branch can be checked out in only one worktree at a time.
