### config-origin

```
bash lab try config-origin
```

1. List every setting Git sees here, with its scope and the file it comes from:

   ```
   git config --list --show-scope --show-origin
   ```

   `system` lines come from Git's install, `global` from your own `.gitconfig` and `local` from this repo's `.git/config`. When a setting appears more than once, the last one wins. On Windows you'll often see `core.autocrlf` twice, `true` from system and `false` from this repo.

2. This repo sets its own email. See every value of `user.email`:

   ```
   git config --show-scope --show-origin --get-all user.email
   ```

   You'll see your global email if you set one, then `local file:.git/config sam@work.example.com`.

3. Ask for the value that wins, and who your next commit here would be by:

   ```
   git config user.email
   git var GIT_AUTHOR_IDENT
   ```

A `-c` on the command line beats every file. Try `git -c user.email=me@example.com config --show-scope user.email`.
