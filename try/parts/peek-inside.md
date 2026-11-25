### peek-inside

```
bash lab try peek-inside
```

1. Look around `.git` first. HEAD names a branch, and the branch is a file holding one commit hash:

   ```
   cat .git/HEAD
   cat .git/refs/heads/main
   ls .git/objects
   ```

2. Show that commit object:

   ```
   git cat-file -p HEAD
   ```

3. Copy the `tree` hash from the output and show that tree:

   ```
   git cat-file -p <tree-hash>
   ```

4. Find the line for `README.md` and show that blob:

   ```
   git cat-file -p <blob-hash>
   ```

5. Ask Git what type each object is: `git cat-file -t <hash>`.

Look for: the hash in `refs/heads/main` is the one `git log -1` shows, and `ls .git/objects` has a folder named after its first two characters.

Extra: `src` is a tree inside the tree. Show it, then compare `git cat-file -p HEAD~1` with `HEAD`: which hashes changed, and which stayed the same?
