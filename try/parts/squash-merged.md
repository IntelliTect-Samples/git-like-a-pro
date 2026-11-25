### squash-merged

```
bash lab try squash-merged
```

`feature` has two commits. You'll play the server: Bitbucket's "Squash" merge strategy puts all of a branch's changes on `main` as one new commit.

1. Squash-merge `feature` into `main`, the way the server would:

   ```
   git merge --squash feature
   git commit -m "Add discounts (#12)"
   ```

2. The work is on `main` now, so delete the branch:

   ```
   git branch -d feature
   ```

   Git refuses: the branch is "not fully merged". `-d` only checks commits, and `feature`'s two commits aren't on `main`. The squash commit is a new commit with the same changes.

3. See the commits Git is worried about, then check that their changes really are on `main`:

   ```
   git log --oneline main..feature
   git diff main feature
   ```

   The log shows both commits; the diff shows nothing, so `main` already has everything `feature` has.

4. Now it's safe to force the delete:

   ```
   git branch -D feature
   ```

   Use `-D` only after a check like step 3. Deleted the wrong branch? Git printed its last commit ("was ..."): `git branch feature <hash>` brings it back.

Extra: build it again, add a commit to `feature` after the squash, then run step 3. What does the diff show now, and would `-D` be safe?
