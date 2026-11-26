### add-patch

```
bash lab try add-patch
```

`src/price.sh` has uncommitted changes. Stage the tax change (8 to 9) and the shipping fix (`-gt` to `-ge`), but not the currency experiment or the debug line. Run `git diff` first to see them.

1. Start staging piece by piece:

   ```
   git add -p
   ```

2. The first hunk has the tax and the currency changes together. Split it:

   ```
   s
   ```

3. Git now asks about each of the three parts in turn. Stage the first one, the tax change, and skip the second, the currency:

   ```
   y
   n
   ```

4. The third prompt is the last hunk. The debug line sits right next to the fix, so `s` isn't offered. Edit it instead:

   ```
   e
   ```

   In the editor, delete the `+  echo "debug: ...` line, then save and close the file. In VS Code that means closing its tab. If nothing opens, or Git carries on at once, set an editor that waits: `git config core.editor "code --wait"`.

5. Check the result:

   ```
   git diff --staged
   git diff
   ```

Only `TAX_PERCENT=9` and `-ge` should be staged. `CURRENCY=EUR` and the debug line stay unstaged, and they're still in the file.

If you have time, commit what you staged and `git stash` the rest. You can also press `?` at the `git add -p` prompt to see every answer it takes.
