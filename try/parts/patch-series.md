### patch-series

```
bash lab try patch-series
```

`shop` has a `feature` branch with two commits. `offline` is a copy of `shop`'s `main` with no remote, like a repo on a network you can't push to.

1. Turn the two commits into patch files:

   ```
   cd shop
   git log --oneline main..feature
   git format-patch main..feature -o ../patches
   ```

   One file per commit, numbered in order. Open one: it's an email with the author, date, message and diff.

2. Apply them in the other repo:

   ```
   cd ../offline
   git am ../patches/*.patch
   ```

3. Compare the commits on both sides:

   ```
   git log --oneline -3
   git -C ../shop log --oneline -3 feature
   ```

   Same messages, same changes, different hashes for the two new commits.

4. See why:

   ```
   git log --format=fuller -1
   ```

   The author and author date came from the patch. The committer is you, and the commit date is now, so the commit object is different and so is its hash.

Extra: from `offline`, run `git show HEAD | git patch-id` and `git -C ../shop show feature | git patch-id`. The first column (the patch ID) matches, the second (the commit) doesn't: `patch-id` hashes only the change, so it spots the same change even when the hashes differ. Rebase and `git cherry` use it to skip changes that are already there.
