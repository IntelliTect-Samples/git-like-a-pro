### peek-inside

```
bash lab try peek-inside
```

1. Start by looking around `.git`. HEAD names a branch, and the branch is a file holding one commit hash:

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

5. Ask Git what type each object is with `git cat-file -t <hash>`.

Is the hash in `refs/heads/main` the one `git log -1` shows? And does `ls .git/objects` have a folder named after its first two characters?

Extra: `src` is a tree inside the tree. Show it, then compare `git cat-file -p HEAD~1` with `HEAD`. Which hashes changed, and which stayed the same?
