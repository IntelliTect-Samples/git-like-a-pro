### folder-remote

```
bash lab try folder-remote
```

The folder holds one repo, `project`. Start with `cd project` and work from inside it.

1. Make an empty bare repo next to it. A bare repo has no working files, like the copy on a server or a USB stick:

   ```
   git init --bare -b main ../usb.git
   ```

2. Add it as a remote and push to it:

   ```
   git remote add usb ../usb.git
   git push usb main
   ```

3. Clone from the folder, as a teammate would:

   ```
   cd ..
   git clone usb.git copy
   cd copy
   git log --oneline --decorate
   ```

The commit hashes should match the ones in `project`, and you'll see `origin/main`. `git remote -v` shows that `origin` is just a folder path.

Extra: commit something in `copy` and `git push`, then `cd ../project` and `git pull usb main`.

Why `-b main` in step 1? Without it the clone may warn "remote HEAD refers to nonexistent ref", because the bare repo's HEAD names your default branch, which is often `master`. On Windows, a commit in `copy` may print "LF will be replaced by CRLF". That's harmless and comes from Git for Windows' line-ending setting.
