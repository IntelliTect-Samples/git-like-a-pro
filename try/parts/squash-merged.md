### squash-merged

```
bash lab try squash-merged
```

`feature` has two commits. You'll play the server here. Bitbucket's "Squash" merge strategy puts all of a branch's changes on `main` as one new commit.

1. Squash-merge `feature` into `main`, the way the server would:

   ```
   git merge --squash feature
   git commit -m "Add discounts (#12)"
   ```

2. The work is on `main` now, so delete the branch:

   ```
   git branch -d feature
   ```

   Git refuses because the branch is "not fully merged". `-d` only checks commits, and `feature`'s two commits aren't on `main`. The squash commit is a new commit that carries the same changes.

3. See the commits Git is worried about, then check that their changes really are on `main`:

   ```
   git log --oneline main..feature
   git diff main feature
   ```

   The log shows both commits, but the diff is empty, so `main` already has everything `feature` has.

4. Now it's safe to force the delete:

   ```
   git branch -D feature
   ```

   Only reach for `-D` after a check like step 3. If you delete the wrong branch, look for the last commit Git printed ("was ...") and run `git branch feature <hash>` to bring it back.

Extra: build it again, add a commit to `feature` after the squash, and repeat step 3. What does the diff show now, and would `-D` still be safe?
