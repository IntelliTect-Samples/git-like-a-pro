### submodule-bump

```
bash lab try submodule-bump
```

Two folder remotes: `lib.git`, a small library with versions `v1.0` and `v1.1`, and `app.git`, which has `lib` as a submodule pinned to `v1.0`.

1. Clone the app and its submodule in one go:

   ```
   git -c protocol.file.allow=always clone --recurse-submodules app.git app
   ```

   The `-c protocol.file.allow=always` is only needed because these remotes are local folders: Git blocks submodules from folders by default. You won't need it with Bitbucket.

2. See which `lib` commit the app uses, and the state inside the submodule:

   ```
   cd app
   git submodule status
   git -C lib status
   ```

   The app records one exact commit (`v1.0`), so Git checks it out as a detached HEAD.

3. Move `lib` to a new version: get on its `main` (that's `v1.1`) and add a fix of your own:

   ```
   cd lib
   git switch main
   echo 'round_dollars() { echo $(( ($1 + 50) / 100 * 100 )); }' >> round.sh
   git commit -am "Add round_dollars"
   cd ..
   ```

4. The app sees the submodule moved. Commit the new pointer like any change:

   ```
   git status
   git diff --submodule=log
   git add lib
   git commit -m "Use lib with round_dollars"
   ```

   `status` says `modified: lib (new commits)`; the diff lists the lib commits you're about to point at.

5. Try to push the app first:

   ```
   git push --recurse-submodules=check
   ```

   Refused: your `lib` commit is on no remote yet, so anyone who pulled the app would get a pointer to a commit they can't fetch.

6. Push in the right order, library first:

   ```
   git -C lib push
   git push
   ```

Extra: make another `lib` change, commit the pointer, and push with `git push --recurse-submodules=on-demand`. Git pushes `lib` first, then the app. Check with a fresh clone: `git -c protocol.file.allow=always clone --recurse-submodules app.git check`.
