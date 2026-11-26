# Lab: Air-gap capstone

About 30 minutes. Section: History cleanup, strategies and structure. Good in pairs: one person is "outside", the other "inside", and only the USB folder passes between you.

On Windows, work in **Git Bash** (in VS Code: Terminal > New Terminal > Git Bash). The commands below assume it; in PowerShell, `bash` can start WSL's Linux instead, and some commands fail there.

Some networks are offline on purpose. Work gets in on removable media, often reviewed on the way. Here:

- `outside/` is the connected repo. Its branch `rates` has three commits: some code, a chart stored in **Git LFS**, and a move of the `vendor/units` **submodule** to a newer version.
- `inside/` is the offline repo. It has `main` but not `rates`.
- `usb/` is the stick. Anything that goes inside has to go through it.
- `units.git` is the library on the outside; `inside-units.git` is the inside's copy of it, which only has the old version.

Bring `rates` inside, find out what doesn't come along on its own, and carry that too.

## Set up

```
bash lab air-gap
```

`cd` into the folder it prints. Needs git-lfs (`bash lab doctor` checks). Start at a later step with `bash lab air-gap --step 2` (or 3). Check progress from the kit folder with `bash lab air-gap --check`; hints with `bash lab hint air-gap <step>`.

Submodule commands here have `-c protocol.file.allow=always`: Git blocks submodules from plain folders by default, and our "servers" are folders. A real network would use a server URL instead.

## Step 1 - Patches, and the LFS file (about 12 minutes)

1. Outside: write the branch as a patch series onto the stick, one file per commit:

   ```
   cd outside
   git format-patch main..rates -o ../usb/patches
   ```

   Open one: it's plain text a reviewer can read. Look at `0002`: the "picture" is a 3-line LFS pointer, not the picture.

2. Inside: apply them on a new branch.

   ```
   cd ../inside
   git switch -c rates
   git am ../usb/patches/*.patch
   ```

   It stops at the second patch with `Error downloading object: assets/chart.png ... smudge filter lfs failed`: Git LFS can't find the chart's content to check it out, and there's no server to download it from.

3. Back out, and clean up the half-written file it left:

   ```
   git am --abort
   git status
   rm assets/chart.png
   ```

4. Carry the LFS objects. They live in `.git/lfs/objects` and aren't part of any patch:

   ```
   cd ../outside
   mkdir -p ../usb/lfs-objects
   cp -R .git/lfs/objects/. ../usb/lfs-objects/
   cd ../inside
   cp -R ../usb/lfs-objects/. .git/lfs/objects/
   git am ../usb/patches/*.patch
   git lg
   ```

   A `warning: unable to rmdir 'vendor/units'` and ` M vendor/units` in `git status` are expected: the branch now wants a newer library than the one checked out. Step 2 fixes that.

## Step 2 - The submodule (about 8 minutes)

1. Inside, still on `rates`: update the submodule to the version the branch now wants.

   ```
   git -c protocol.file.allow=always submodule update
   ```

   It fails: the commit isn't in `inside-units.git`. A patch only carries the submodule's commit ID, never the library's commits.

2. Outside: bundle just the library commits the inside is missing (`v1.0` is the last version it has), plus the `v1.1` tag. Run this from the workspace folder (`cd ..` from `inside/`):

   ```
   cd ..
   git -C units.git bundle create ../usb/units.bundle v1.0..main v1.1
   ```

3. Inside: fetch the branch and the tag from the bundle into the inside's copy of the library, then update again. `git -C <folder>` runs one command as if you were in that folder. `main:main` and `refs/tags/v1.1:refs/tags/v1.1` say "take this ref from the bundle and store it under that name here".

   ```
   git -C inside-units.git fetch ../usb/units.bundle main:main refs/tags/v1.1:refs/tags/v1.1
   cd inside
   git -c protocol.file.allow=always submodule update
   git submodule status
   ```

## Step 3 - The whole branch as a bundle (about 5 minutes)

A bundle carries real commits, so the hashes stay the same. Patches make new commits.

```
cd ../outside
git bundle create ../usb/rates.bundle main..rates
cd ../inside
git bundle verify ../usb/rates.bundle
git fetch ../usb/rates.bundle rates:rates-bundle
git rev-parse rates rates-bundle
git -C ../outside rev-parse rates
```

`rates-bundle` matches the outside exactly; `rates` (from patches) doesn't. Same code, different commits.

## Stretch

- The next trip, with an incremental bundle. Outside, mark what you just sent with `git tag last-sent rates`, add a commit to `rates`, then bundle only the new part: `git bundle create ../usb/rates-2.bundle last-sent..rates` (afterwards, `git tag -f last-sent rates` moves the mark for the next trip). Inside, `git bundle verify ../usb/rates-2.bundle` checks that the commit it builds on is already there (it is: `rates-bundle`), then `git fetch ../usb/rates-2.bundle rates:rates-bundle`.
- A bare repo on the stick is a third way: `git init --bare -b main ../usb/shop.git`, then outside `git remote add usb ../usb/shop.git` and `git push usb rates`, and inside fetch from it. Use a named remote: pushing straight to the folder path fails on the LFS file ("missing protocol"), while `git push usb` carries the LFS objects too. It still doesn't carry the library.
- Which would your reviewers rather read: patches or a bundle? Which keeps `git log` the same on both sides?
- `git am` keeps the author and the author date, but the committer is whoever applied it. Check with `git log --format=fuller -1 rates`.

## Debrief

- What didn't cross with the patches, and how would you have noticed if `git am` hadn't stopped?
- Why do clean commits (Day 1) matter more when every commit becomes a file someone reviews?
- What would you put on a checklist for the person carrying the stick?
