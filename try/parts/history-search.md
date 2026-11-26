### history-search

```
bash lab try history-search
```

1. Find the commit that added the free shipping limit. `-S` lists the commits that change how many times the text appears:

   ```
   git log -S FREE_SHIPPING_OVER --oneline
   ```

   You get only "Add shipping costs". Add `-p` to watch the line arrive in the diff.

2. The limit was changed later, but that commit didn't add or remove the text, so `-S` skipped it. `-G` lists every commit whose diff has a line matching the text, which it treats as a regular expression:

   ```
   git log -G FREE_SHIPPING_OVER --oneline
   ```

   Now "Raise the free shipping limit" shows up too.

3. Two dots give you the commits on `feature` that aren't on `main`:

   ```
   git log --oneline main..feature
   ```

   That's the three loyalty commits. Swap the names (`feature..main`) and you get the two tax commits instead.

4. Three dots give the commits on either side, but not on both:

   ```
   git log --oneline --left-right main...feature
   ```

   All five appear. `<` marks the ones only on `main` and `>` the ones only on `feature`.

Extra: `git diff` reads the dots differently. Compare `git diff --stat main...feature`, which shows only `feature`'s changes since it branched (what a pull request shows), with `git diff --stat main feature`, which compares the two snapshots so `main`'s tax changes show up reversed.
