### ff-only

```
bash lab try ff-only
```

`docs` is directly ahead of `main`. `feature` branched off earlier, and `main` has moved on since then. `git lg --all` shows the picture.

1. Try to fast-forward `main` to `feature`:

   ```
   git merge --ff-only feature
   ```

   Git refuses with `fatal: Not possible to fast-forward, aborting.` and nothing changes.

2. The same with `docs` works, because `main` only has to move forward:

   ```
   git merge --ff-only docs
   git lg --all
   ```

   Git reports "Fast-forward". `main` now points at the same commit as `docs`, and there's no merge commit.

3. Undo that, then merge `docs` again, forcing a merge commit:

   ```
   git reset --hard ORIG_HEAD
   git merge --no-ff --no-edit docs
   git lg --all
   ```

This time there's a "Merge branch 'docs'" commit with two parents. The history now records that `docs` was a branch, even though a fast-forward was possible.

Now try `git merge --no-edit feature`. Does it need `--no-ff`?
