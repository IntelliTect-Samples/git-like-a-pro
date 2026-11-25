### ignore-rules

```
bash lab try ignore-rules
```

1. See the files Git is ignoring:

   ```
   git status --ignored
   ```

   `build/` and `server.log` (and `.git-lab-workspace`, the kit's marker file).

2. Ask which rule ignores each one:

   ```
   git check-ignore -v server.log build/app.js
   ```

   Each line is `file:line:pattern`, then the path: `server.log` is ignored by line 2 of `.gitignore`, `*.log`.

3. `debug.log` matches `*.log` too, but Git still tracks it, because it was committed before the rule. Ask about it:

   ```
   git check-ignore -v debug.log
   ```

   No output: ignore rules never apply to tracked files.

4. Stop tracking it, but keep the file on disk:

   ```
   git rm --cached debug.log
   git commit -m "Stop tracking debug.log"
   git check-ignore -v debug.log
   ```

Look for: `debug.log` is still in the folder, `git status` is clean, and step 3's command now names the `*.log` rule.

Extra: `keep.log` matches `*.log` but is committed on purpose. `git check-ignore -v --no-index keep.log` checks it as if it weren't tracked: which rule wins? Then try `git check-ignore -v .git-lab-workspace`: rules can live outside `.gitignore` too.
