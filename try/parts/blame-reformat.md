### blame-reformat

```
bash lab try blame-reformat
```

Alex wrote `src/price.sh`. Sam then re-indented it (whitespace only) and moved `discount()` to its own file.

1. Blame the file:

   ```
   git blame src/price.sh
   ```

   The re-indented lines (2-4) all point at Sam's "Reformat with 4-space indent" commit, which isn't the commit you want.

2. Ignore whitespace changes:

   ```
   git blame -w src/price.sh
   ```

   Every line is Alex's now (`^` marks the first commit in the history).

3. Blame the moved function, first plainly, then following moved lines:

   ```
   git blame src/discount.sh
   git blame -w -C -C src/discount.sh
   ```

   The first says Sam wrote it all in the move commit. The second finds the lines in `src/price.sh` and shows Alex. `-C` looks for lines moved from files changed in the same commit; `-C -C` also searches the other files of the commit that created the file.

4. Skip the reformat for everyone, without `-w`: list it in an ignore file and point Git at it:

   ```
   git log --format=%H --grep=Reformat > .git-blame-ignore-revs
   git config blame.ignoreRevsFile .git-blame-ignore-revs
   git blame src/price.sh
   ```

   Plain `blame` shows Alex now. Teams commit `.git-blame-ignore-revs` to the repo; each person (or the setup script) runs the `git config` line once.

Extra: run `git config blame.markIgnoredLines true` and blame again. A `?` marks lines that Git moved past an ignored commit (here it shows as `^?`: the `^` means those lines come from the very first commit).
