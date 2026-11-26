### pull-rebase

```
bash lab try pull-rebase
```

The folder holds the shared remote `origin.git` and your clone `me`. A teammate has pushed a commit you haven't fetched, and you have one commit you haven't pushed. You'll work from `me`, so start with `cd me`.

1. Pull with a merge:

   ```
   git pull --no-rebase --no-edit
   git lg --all
   ```

   You get a merge commit, "Merge branch 'main' of ..." followed by the practice folder's path, joining your commit and the teammate's.

2. Undo that pull. `ORIG_HEAD` is where `main` was before it:

   ```
   git reset --hard ORIG_HEAD
   ```

3. Pull again, rebasing this time:

   ```
   git pull --rebase
   git lg --all
   ```

Now the history is a straight line, with your "Print a receipt" on top of the teammate's "Add shipping cost". The files match step 1 and there's no merge commit, but your commit has a new hash.

Which one does a plain `git pull` give you? `git config --show-origin pull.rebase` will tell you. This repo sets it to `false`.
