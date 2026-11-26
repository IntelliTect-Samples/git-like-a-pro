### tags

```
bash lab try tags
```

1. Make a lightweight tag on the latest commit:

   ```
   git tag try-this
   ```

2. Make an annotated tag on the commit before it:

   ```
   git tag -a v1.0 -m "Release 1.0" HEAD~1
   ```

3. Ask Git what each tag points to:

   ```
   git cat-file -t try-this
   git cat-file -t v1.0
   ```

   `try-this` is only a name for a commit, so you get `commit`. `v1.0` is an object of its own, so you get `tag`.

4. Look inside the tag object:

   ```
   git cat-file -p v1.0
   ```

   It records the commit it points to, the tag name, who tagged it and when (that's you, just now), and the message.

Now run `git describe`, then `git describe --tags`. Why does the first one skip `try-this`? Plain `describe` uses only annotated tags, so it prints something like `v1.0-1-g<hash>`, meaning one commit after v1.0.
