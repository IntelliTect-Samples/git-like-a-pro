### peek-inside

```
bash lab try peek-inside
```

1. Show the latest commit object:

   ```
   git cat-file -p HEAD
   ```

2. Copy the `tree` hash from the output and show that tree:

   ```
   git cat-file -p <tree-hash>
   ```

3. Find the line for `README.md` and show that blob:

   ```
   git cat-file -p <blob-hash>
   ```

4. Ask Git what type each object is: `git cat-file -t <hash>`.

Extra: `src` is a tree inside the tree. Show it, then compare `git cat-file -p HEAD~1` with `HEAD`: which hashes changed, and which stayed the same?
