# Hints: Air-gap capstone

Show one with `bash lab hint air-gap <step>`.

## Step 1 - Patches, and the LFS file

- The error says the LFS "smudge" filter failed. Git LFS tried to swap the pointer for the real file, couldn't find it locally, and had no server to download it from.
- `git am --abort` puts the branch back but leaves the half-written `assets/chart.png` behind as an untracked file. Delete it, or the next `git am` stops with "already exists in working directory".
- LFS content is stored by hash in `.git/lfs/objects/<2 chars>/<2 chars>/<hash>`. Copying the whole folder is the simple way. If you want just the hashes the branch adds, `git lfs ls-files -l main rates` lists them (that's two refs, not a `main..rates` range).
- Make sure you're on `rates` before the second `git am` (`git switch rates`).

## Step 2 - The submodule

- `git ls-tree rates vendor/units` shows the commit the branch wants, and `git -C ../inside-units.git log --oneline --all` shows what the inside has.
- `v1.0..main` means "everything on main that v1.0 doesn't have", which keeps the bundle small. Adding `v1.1` carries that tag as well. This only works if the inside already has `v1.0`, and `git -C inside-units.git bundle verify ../usb/units.bundle` tells you if anything's missing. Verify needs a repo to check against.
- Run the `-C units.git` command from the workspace folder, the one with `outside`, `inside` and `usb` in it. Think of `-C` as `cd` for one command.

## Step 3 - The whole branch as a bundle

- `rates:rates-bundle` means "take the bundle's `rates` and store it here as `rates-bundle`", so it doesn't clash with the branch you made from patches.
- The two branches have the same files (`git diff rates rates-bundle` is empty) but different commit hashes, because `git am` made new commits with you as the committer.
