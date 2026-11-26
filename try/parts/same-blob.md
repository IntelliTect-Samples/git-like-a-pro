### same-blob

```
bash lab try same-blob
```

1. List every file in the latest commit with its blob hash:

   ```
   git ls-tree -r HEAD
   ```

   `LICENSE.txt` and `docs/LICENSE.txt` have the same hash. Same content means one blob.

2. Count the objects in the repo:

   ```
   git count-objects -v
   ```

   It reports `count: 5`. That's 1 commit, 2 trees (the root and `docs`) and 2 blobs for 3 files.

3. Hash the file yourself. Git hashes only the content, because the file name lives in the tree:

   ```
   git hash-object LICENSE.txt
   ```

Extra: copy a file under a new name and stage it with `cp README.md notes.md` and `git add notes.md`. Does `git count-objects -v` go up? It doesn't, since the content is the same and so is the blob. Only the tree you'd commit next would be new.
