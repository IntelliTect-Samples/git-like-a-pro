### stash-branch

```
bash lab try stash-branch
```

You're halfway through a search feature on `main`, with a change to `src/price.sh` and a new file, `src/search.sh`. `git status --short` shows both.

1. Put it all away. The `-u` takes the new file along too:

   ```
   git stash -u -m "half-done search"
   git status --short
   ```

   `git status --short` prints nothing now, so the working tree is clean.

2. See what the stash holds:

   ```
   git stash list
   git stash show -u
   ```

3. You decide it deserves its own branch. Make one and bring the work back in one go:

   ```
   git stash branch search
   ```

You should be on `search` with both files back, `src/search.sh` still untracked, and the stash gone from `git stash list`. The branch starts at the commit you stashed from, so the work applies cleanly even if `main` has moved on since.

For comparison, rebuild the Try-it and run plain `git stash`. What does `git status --short` show?
