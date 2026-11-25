### add-patch

```
bash lab try add-patch
```

`src/price.sh` has uncommitted changes. Stage the tax change (8 to 9) and the shipping fix (`-gt` to `-ge`), but not the currency experiment or the debug line. See them first with `git diff`.

1. Start staging piece by piece:

   ```
   git add -p
   ```

2. The first hunk has the tax and the currency changes together. Split it:

   ```
   s
   ```

3. Git now asks about each of the three parts in turn. Stage the first (the tax change), skip the second (the currency):

   ```
   y
   n
   ```

4. The third prompt is the last hunk: it has the debug line right next to the fix, so `s` isn't offered. Edit it instead:

   ```
   e
   ```

   In the editor, delete the `+  echo "debug: ...` line, save and close the file (in VS Code, close its tab). If nothing opens, or Git carries on at once, set an editor that waits: `git config core.editor "code --wait"`.

5. Check the result:

   ```
   git diff --staged
   git diff
   ```

Look for: staged are only `TAX_PERCENT=9` and `-ge`; `CURRENCY=EUR` and the debug line are still unstaged, and still in the file.

Extra: commit what you staged, then `git stash` the rest. Or press `?` at the `git add -p` prompt to see every answer it takes.
