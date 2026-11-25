# Try-its

Short exercises during the talk, 2-5 minutes each. Every Try-it builds its own small repo, so you can do any of them at any time, in any order. Build one, then `cd` into the folder it prints.

Stuck or out of time? Skip it. Nothing later depends on it.

## Playground

```
bash lab play
```

A small repo with a few commits on `main` and a `feature` branch. Experiment freely; run the command again to reset it.

## How Git really works

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
