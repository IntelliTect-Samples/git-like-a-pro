### reset-modes

```
bash lab try reset-modes
```

The last commit, "Add a 10% discount", adds one line to `src/price.sh`. Undo it three ways and watch where the change ends up. After each reset, `ORIG_HEAD` is where `main` was before it.

1. `--soft` moves only the branch, so the change is still staged:

   ```
   git reset --soft HEAD~1
   git status --short
   ```

   You'll see `M  src/price.sh`. An `M` in the first column means staged. Put the commit back:

   ```
   git reset --hard ORIG_HEAD
   ```

2. `--mixed`, the default, also resets the staging area. The change is still in the file, but unstaged:

   ```
   git reset HEAD~1
   git status --short
   ```

   This time it's ` M src/price.sh`, with the `M` in the second column. Put it back again:

   ```
   git reset --hard ORIG_HEAD
   ```

3. `--hard` resets the files too, and the change is gone from disk:

   ```
   git reset --hard HEAD~1
   git status --short
   cat src/price.sh
   ```

   The reset prints "HEAD is now at ...", `git status` prints nothing, and there's no `DISCOUNT_PERCENT` line in the file.

4. Even that is recoverable, because the commit still exists:

   ```
   git reset --hard ORIG_HEAD
   git lg
   ```

Extra: `--hard` can't bring back changes you never committed. Edit `README.md`, run `git reset --hard`, and check `git reflog`. Is your edit anywhere?
