### tracking

```
bash lab try tracking
```

The folder holds the shared remote `origin.git`, your clone `me` and your teammate Alex's clone `teammate`. Work from `me`: `cd me`.

1. Check where you stand:

   ```
   git status
   ```

   "Your branch is up to date with 'origin/main'."

2. Make Alex push a commit:

   ```
   bash ../teammate.sh
   ```

3. Check again:

   ```
   git status
   ```

   Still "up to date". Git compares `main` with `origin/main`, your local copy of the remote branch, and nothing has updated that copy yet. `git ls-remote origin main` asks the remote itself: a different hash from `git rev-parse main`.

4. Fetch, then look again:

   ```
   git fetch
   git status
   git lg --all
   ```

   Now you're "behind 'origin/main' by 1 commit". Fetch moved `origin/main` to Alex's commit; `main` and your files didn't change.

5. Move `main` up to it:

   ```
   git merge --ff-only origin/main
   ```

Extra: rebuild the Try-it, run `bash ../teammate.sh`, then `git branch -vv` before and after `git fetch`. The `[origin/main: behind 1]` it shows is only as fresh as your last fetch.
