### ff-only

```
bash lab try ff-only
```

`docs` is directly ahead of `main`. `feature` branched off earlier, and `main` has moved on since. See it with `git lg --all`.

1. Try to fast-forward `main` to `feature`:

   ```
   git merge --ff-only feature
   ```

   Git refuses: `fatal: Not possible to fast-forward, aborting.` Nothing changed.

2. The same with `docs` works, because `main` only has to move forward:

   ```
   git merge --ff-only docs
   git lg --all
   ```

   "Fast-forward": `main` now points at the same commit as `docs`. No merge commit.

3. Undo that, then merge `docs` again, forcing a merge commit:

   ```
   git reset --hard ORIG_HEAD
   git merge --no-ff --no-edit docs
   git lg --all
   ```

Look for: a "Merge branch 'docs'" commit with two parents. The history now shows that `docs` was a branch, even though a fast-forward was possible.

Extra: `git merge --no-edit feature`. Does it need `--no-ff`?
