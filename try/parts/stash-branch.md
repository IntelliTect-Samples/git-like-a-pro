### stash-branch

```
bash lab try stash-branch
```

You're halfway through a search feature on `main`: a change to `src/price.sh` and a new file, `src/search.sh`. See it with `git status --short`.

1. Put it all away, the new file included (`-u`):

   ```
   git stash -u -m "half-done search"
   git status --short
   ```

   `git status --short` prints nothing: the working tree is clean.

2. See what the stash holds:

   ```
   git stash list
   git stash show -u
   ```

3. Decide it deserves its own branch. Make one and bring the work back in one go:

   ```
   git stash branch search
   ```

Look for: you're on `search`, both files are back (`src/search.sh` still untracked), and the stash is gone from `git stash list`. The branch starts at the commit you stashed from, so the work applies cleanly even if `main` has moved on since.

Extra: rebuild the Try-it and run plain `git stash`. What does `git status --short` show?
