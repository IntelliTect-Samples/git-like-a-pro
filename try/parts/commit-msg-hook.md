### commit-msg-hook

```
bash lab try commit-msg-hook
```

The repo has a shared hook in `.githooks/commit-msg`, committed like any other file.

1. Read the hook, and see how Git stored it:

   ```
   cat .githooks/commit-msg
   git ls-files -s .githooks
   ```

   It's a plain `sh` script: Git passes it the message file, and a non-zero exit stops the commit. Mode `100755` means it was committed as executable, so it can run on macOS and Linux after a clone. (Git for Windows ignores that bit and runs any hook file that starts with `#!`.)

2. Git doesn't run it yet. Hooks run only from the `core.hooksPath` folder (`.git/hooks` unless you change it), and cloning never turns hooks on for you. Point this repo at the shared folder:

   ```
   git config core.hooksPath .githooks
   ```

   `core.hooksPath` replaces the hooks folder, it doesn't add one: any hooks from your own global `core.hooksPath` stop running in this repo. (The kit already set this repo's `core.hooksPath` to `.git/hooks`, so your global hooks weren't running here before either.)

3. Commit without a ticket key:

   ```
   echo "Free shipping over 50" >> notes.txt
   git commit -am "Add free shipping idea"
   ```

   The hook prints its message and the commit doesn't happen. `git status` shows your change is still there.

4. Add a key and commit again:

   ```
   git commit -am "PROJ-42 Add free shipping idea"
   ```

5. Skip the hook for one commit:

   ```
   echo "Gift cards" >> notes.txt
   git commit -am "Add gift cards idea" --no-verify
   git log --oneline
   ```

   `--no-verify` skips `commit-msg` (and `pre-commit`). So a hook is a convenience: a rule that must always hold also needs a check on the server.

Extra: make the hook also reject a message whose first line is longer than 72 characters, then test it. Your edit takes effect right away; no need to run `git config` again.
