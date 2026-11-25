### pull-rebase

```
bash lab try pull-rebase
```

The folder holds the shared remote `origin.git` and your clone `me`. A teammate has pushed a commit you haven't fetched, and you have one commit you haven't pushed. Work from `me`: `cd me`.

1. Pull with a merge:

   ```
   git pull --no-rebase --no-edit
   git lg --all
   ```

   A merge commit, "Merge branch 'main' of ..." (then the practice folder's path), joins your commit and the teammate's.

2. Undo that pull. `ORIG_HEAD` is where `main` was before it:

   ```
   git reset --hard ORIG_HEAD
   ```

3. Pull again, rebasing this time:

   ```
   git pull --rebase
   git lg --all
   ```

Look for: a straight line, with your "Print a receipt" on top of the teammate's "Add shipping cost". Same files as in step 1, no merge commit, but your commit has a new hash.

Extra: which one do you get from a plain `git pull`? `git config --show-origin pull.rebase` tells you (this repo sets it to `false`).
