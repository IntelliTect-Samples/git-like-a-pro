### reflog-rescue

```
bash lab try reflog-rescue
```

`experiment` has two commits that aren't on `main`. See them with `git lg --all`.

1. Delete the branch, as if by accident:

   ```
   git branch -D experiment
   ```

   `git lg --all` no longer shows its commits.

2. Look at where HEAD has been:

   ```
   git reflog
   ```

   Find `commit: Limit coupons to one per order`, the last commit made on `experiment`. Its name is on the same line: `HEAD@{2}`.

3. Put a branch back on it:

   ```
   git branch experiment HEAD@{2}
   git lg --all
   ```

Look for: `experiment` is back with both commits, "Try coupons" and "Limit coupons to one per order".

Extra: after step 3, `git reflog experiment` shows only one entry. Deleting a branch deletes its own reflog; it was HEAD's reflog that saved you. And `git branch -D` printed the hash too (`was <hash>`): `git branch experiment <hash>` works as well.
