### history-search

```
bash lab try history-search
```

1. Find the commit that added the free shipping limit. `-S` lists commits that change how many times the text appears:

   ```
   git log -S FREE_SHIPPING_OVER --oneline
   ```

   Only "Add shipping costs". Add `-p` to see the line arrive in the diff.

2. The limit was changed later, but that commit didn't add or remove the text, so `-S` skipped it. `-G` lists every commit whose diff has a line matching the text (a regular expression):

   ```
   git log -G FREE_SHIPPING_OVER --oneline
   ```

   Now "Raise the free shipping limit" shows up too.

3. Two dots: commits on `feature` that aren't on `main`:

   ```
   git log --oneline main..feature
   ```

   The three loyalty commits. Swap the names (`feature..main`) to see the two tax commits instead.

4. Three dots: commits on either side, but not on both:

   ```
   git log --oneline --left-right main...feature
   ```

   All five: `<` marks the ones only on `main`, `>` the ones only on `feature`.

Extra: for `git diff` the dots mean something else. Compare `git diff --stat main...feature` (only `feature`'s changes since it branched, like a pull request shows) with `git diff --stat main feature` (the two snapshots, so `main`'s tax changes show up reversed).
