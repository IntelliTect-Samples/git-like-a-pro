### reflog-rescue

```
bash lab try reflog-rescue
```

`experiment` has two commits that aren't on `main`. You can see them with `git lg --all`.

1. Delete the branch, as if by accident:

   ```
   git branch -D experiment
   ```

   `git lg --all` no longer shows its commits.

2. Look at where HEAD has been:

   ```
   git reflog
   ```

   Find `commit: Limit coupons to one per order`, the last commit made on `experiment`. Its name, `HEAD@{2}`, is on the same line.

3. Put a branch back on it:

   ```
   git branch experiment HEAD@{2}
   git lg --all
   ```

`experiment` should be back with both commits, "Try coupons" and "Limit coupons to one per order".

Extra: run `git reflog experiment` now and it shows only one entry. Deleting a branch deletes its own reflog too, so it was HEAD's reflog that saved you. `git branch -D` also printed the hash (`was <hash>`), and `git branch experiment <hash>` works as well.
