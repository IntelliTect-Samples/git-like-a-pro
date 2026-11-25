### folder-remote

```
bash lab try folder-remote
```

The folder holds one repo, `project`. Work from inside it: `cd project`.

1. Make an empty bare repo next to it (no working files, like the copy on a server or a USB stick):

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

Look for: the same commit hashes as in `project`, and `origin/main`. `git remote -v` shows that `origin` is just a folder path.

Extra: commit something in `copy` and `git push`, then `cd ../project` and `git pull usb main`. Why `-b main` in step 1? Leave it out and the clone may warn "remote HEAD refers to nonexistent ref": the bare repo's HEAD names your default branch, often `master`.
