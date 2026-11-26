### cherry-pick-hotfix

```
bash lab try cherry-pick-hotfix
```

`release/1.0` branched off before `main` got two features, with a fix landing between them. Ship only the fix to the release.

1. Find the fix on `main` and copy its hash:

   ```
   git log --oneline main
   ```

2. Switch to the release branch and copy the fix onto it. The `-x` records where it came from:

   ```
   git switch release/1.0
   git cherry-pick -x <hash-of-Fix-tax-rounding>
   ```

3. Look at the new commit and the graph:

   ```
   git log -1
   git lg --all
   ```

The message should end with `(cherry picked from commit <hash>)`. "Fix tax rounding" is now on both branches with different hashes, while "Print a receipt" and "Add search" stayed on `main`.

Extra: `git cherry -v main` checks each release commit against `main`, and a `+` means `main` has no such change. Which line starts with `-`, and why?
