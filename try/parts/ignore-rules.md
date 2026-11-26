### ignore-rules

```
bash lab try ignore-rules
```

1. See the files Git is ignoring:

   ```
   git status --ignored
   ```

   You'll see `build/` and `server.log`, plus `.git-lab-workspace`, the kit's marker file.

2. Ask which rule ignores each one:

   ```
   git check-ignore -v server.log build/app.js
   ```

   Each line gives `file:line:pattern` and then the path. So `server.log` is ignored by line 2 of `.gitignore`, which is `*.log`.

3. `debug.log` matches `*.log` too, but Git still tracks it, because it was committed before the rule. Ask about it:

   ```
   git check-ignore -v debug.log
   ```

   No output. Ignore rules never apply to tracked files.

4. Stop tracking it, but keep the file on disk:

   ```
   git rm --cached debug.log
   git commit -m "Stop tracking debug.log"
   git check-ignore -v debug.log
   ```

Afterwards `debug.log` is still in the folder, `git status` is clean, and the command from step 3 now names the `*.log` rule.

Extra: `keep.log` matches `*.log` but was committed on purpose. `git check-ignore -v --no-index keep.log` checks it as if it weren't tracked. Which rule wins? Then try `git check-ignore -v .git-lab-workspace` to see that rules can live outside `.gitignore` too.
