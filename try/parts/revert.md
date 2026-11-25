### revert

```
bash lab try revert
```

The folder holds the shared remote `origin.git` and your clone `me`. Everything is pushed, including "Update tax", which set the tax to 80%. Work from `me`: `cd me`.

1. Make a new commit that undoes it:

   ```
   git revert --no-edit HEAD~1
   ```

2. Look at what revert made:

   ```
   git show
   ```

   The message says `This reverts commit <hash>.` and the diff puts `TAX_PERCENT=8` back.

3. Share it the normal way:

   ```
   git push
   git lg
   ```

Look for: "Update tax" is still in the history, with the revert on top. Nothing was rewritten, so nobody needs to force-push or re-clone.

Extra: revert the revert (`git revert --no-edit HEAD`). What does `src/price.sh` say now?
