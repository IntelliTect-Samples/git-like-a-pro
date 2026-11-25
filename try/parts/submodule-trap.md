### submodule-trap

```
bash lab try submodule-trap
```

`app` is a clone with a `lib` submodule. Someone made a commit inside `lib` and never pushed it. Find it before it's lost.

1. Look from the app:

   ```
   cd app
   git status
   git submodule status
   ```

   `status` says `modified: lib (new commits)`. The `+` in front of the submodule's hash means `lib` is on a different commit than the one the app records. The name in brackets, like `heads/main-1-g...`, is `git describe` for that commit: one commit after `main`.

2. See which commits:

   ```
   git diff --submodule=log
   ```

3. Look inside the submodule:

   ```
   cd lib
   git status
   git log --oneline origin/main..HEAD
   ```

   `HEAD detached from ...`: there's no branch here, because a submodule checkout always starts detached. The log shows the commit that is on no remote. If you switched to `main` now, Git would warn that you're leaving it behind.

4. Put it on a branch and push it, so it's safe:

   ```
   git switch -c round-dollars
   git push -u origin round-dollars
   ```

Extra: in `app`, run `git config status.submoduleSummary true`, then `git status`. It now lists the submodule's commits too, which makes this trap easier to spot every day.
