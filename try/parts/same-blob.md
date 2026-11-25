### same-blob

```
bash lab try same-blob
```

1. List every file in the latest commit with its blob hash:

   ```
   git ls-tree -r HEAD
   ```

   `LICENSE.txt` and `docs/LICENSE.txt` have the same hash: same content, one blob.

2. Count the objects in the repo:

   ```
   git count-objects -v
   ```

   `count: 5`: 1 commit, 2 trees (the root and `docs`) and 2 blobs for 3 files.

3. Hash the file yourself. Git hashes only the content; the file name lives in the tree:

   ```
   git hash-object LICENSE.txt
   ```

Extra: copy a file under a new name and stage it (`cp README.md notes.md`, then `git add notes.md`). Does `git count-objects -v` go up? (No: same content, same blob. Only the new tree you'd commit would be new.)
