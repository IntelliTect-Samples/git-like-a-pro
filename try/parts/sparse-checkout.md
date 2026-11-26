### sparse-checkout

```
bash lab try sparse-checkout
```

A small monorepo, with `web`, `api`, `mobile` and `docs` side by side.

1. Keep only the folders you work on, using the default cone mode:

   ```
   git sparse-checkout set api docs
   ls
   ```

   `web` and `mobile` are gone from disk. Top-level files like `README.md` always stay.

2. Ask Git what's going on:

   ```
   git sparse-checkout list
   git status
   ```

   `status` tells you you're in a sparse checkout with 56% of tracked files present. Nothing was deleted from history, and the other files are still in every commit.

3. Add part of a folder:

   ```
   git sparse-checkout add web/css
   ls web
   ```

   You get `web/css` and also `web/index.html`, because cone mode always includes the files directly inside each parent folder.

4. Get everything back:

   ```
   git sparse-checkout disable
   ls
   ```

Want proof the files never stopped being tracked? Run `git sparse-checkout set api docs` again, then `git ls-files -t`. Every file is listed. `H` means it's on disk and `S` means sparse checkout skipped it.
