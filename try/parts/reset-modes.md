### reset-modes

```
bash lab try reset-modes
```

The last commit, "Add a 10% discount", adds one line to `src/price.sh`. Undo it three ways and watch where the change ends up. After each reset, `ORIG_HEAD` is where `main` was before it.

1. `--soft` moves the branch only. The change is still staged:

   ```
   git reset --soft HEAD~1
   git status --short
   ```

   `M  src/price.sh` (the `M` in the first column means staged). Put the commit back:

   ```
   git reset --hard ORIG_HEAD
   ```

2. `--mixed` (the default) also resets the staging area. The change is still in the file, unstaged:

   ```
   git reset HEAD~1
   git status --short
   ```

   ` M src/price.sh` (the `M` in the second column). Put it back again:

   ```
   git reset --hard ORIG_HEAD
   ```

3. `--hard` resets the files too. The change is gone from disk:

   ```
   git reset --hard HEAD~1
   git status --short
   cat src/price.sh
   ```

   `git status` prints nothing (the reset itself prints "HEAD is now at ..."), and there's no `DISCOUNT_PERCENT` line.

4. Even that is recoverable, because the commit still exists:

   ```
   git reset --hard ORIG_HEAD
   git lg
   ```

Extra: `--hard` can't bring back changes you never committed. Edit `README.md`, run `git reset --hard`, and check `git reflog`: is your edit anywhere?
