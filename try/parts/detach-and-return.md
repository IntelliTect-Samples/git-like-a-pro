### detach-and-return

```
bash lab try detach-and-return
```

1. Check out an older commit directly, not a branch:

   ```
   git switch --detach HEAD~1
   ```

   `git status` now says `HEAD detached at <hash>`.

2. Make a commit there:

   ```
   echo "FREE_SHIPPING_FROM=5000" >> src/price.sh
   git commit -am "Try free shipping"
   ```

3. Go back to `main` and read the warning: Git says you are leaving 1 commit behind and prints its hash.

   ```
   git switch main
   ```

4. `git lg --all` no longer shows "Try free shipping": no branch points to it. Give it one. `HEAD@{1}` means "where HEAD was one move ago":

   ```
   git branch free-shipping HEAD@{1}
   git lg --all
   ```

Look for: `free-shipping` branching off "Add price settings", next to `main`.

Extra: `git switch -c <name>` while detached keeps the commits too. Try it: `git switch --detach main`, commit something, then `git switch -c keep-it`.
