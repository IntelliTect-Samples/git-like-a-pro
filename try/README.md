# Try-its

Short exercises during the talk, 2-10 minutes each. Every Try-it builds its own small repo, so you can do any of them at any time, in any order. Build one, then `cd` into the folder it prints.

Stuck or out of time? Skip it. Nothing later depends on it. "(if time)" marks the ones the class may skip; they're good for later.

This file is generated from `try/parts/` by `bash tests/build-try-readme.sh`: edit the parts, not this file.

## Playground

```
bash lab play
```

A small repo with a few commits on `main` and a `feature` branch. Experiment freely; run the command again to reset it.

## How Git really works

### peek-inside (4 min)

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

### detach-and-return (4 min)

```
bash lab try detach-and-return
```

1. Check out an older commit directly, not a branch:

   ```
   git switch --detach HEAD~1
   ```

   `git status` now says `HEAD detached at <hash>`.

2. Make a commit there:

   ```
   echo "FREE_SHIPPING_FROM=5000" >> src/price.sh
   git commit -am "Try free shipping"
   ```

3. Go back to `main` and read the warning: Git says you are leaving 1 commit behind and prints its hash.

   ```
   git switch main
   ```

4. `git lg --all` no longer shows "Try free shipping": no branch points to it. Give it one. `HEAD@{1}` means "where HEAD was one move ago":

   ```
   git branch free-shipping HEAD@{1}
   git lg --all
   ```

Look for: `free-shipping` branching off "Add price settings", next to `main`.

Extra: `git switch -c <name>` while detached keeps the commits too. Try it: `git switch --detach main`, commit something, then `git switch -c keep-it`.

### folder-remote (4 min)

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

### same-blob (2 min, if time)

```
bash lab try same-blob
```

1. List every file in the latest commit with its blob hash:

   ```
   git ls-tree -r HEAD
   ```

   `LICENSE.txt` and `docs/LICENSE.txt` have the same hash: same content, one blob.

2. Count the objects in the repo:

   ```
   git count-objects -v
   ```

   `count: 5`: 1 commit, 2 trees (the root and `docs`) and 2 blobs for 3 files.

3. Hash the file yourself. Git hashes only the content; the file name lives in the tree:

   ```
   git hash-object LICENSE.txt
   ```

Extra: copy a file under a new name and stage it (`cp README.md notes.md`, then `git add notes.md`). Does `git count-objects -v` go up? (No: same content, same blob. Only the new tree you'd commit would be new.)

### tags (3 min, if time)

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

   `try-this` is just a name for a commit (`commit`). `v1.0` is its own object (`tag`).

4. Look inside the tag object:

   ```
   git cat-file -p v1.0
   ```

   It records the commit it points to, the tag name, who tagged it and when (you, just now), and the message.

Extra: run `git describe`, then `git describe --tags`. Why does the first one skip `try-this`? (Plain `describe` uses only annotated tags; it prints something like `v1.0-1-g<hash>`: one commit after v1.0.)

### tracking (3 min)

```
bash lab try tracking
```

The folder holds the shared remote `origin.git`, your clone `me` and your teammate Alex's clone `teammate`. Work from `me`: `cd me`.

1. Check where you stand:

   ```
   git status
   ```

   "Your branch is up to date with 'origin/main'."

2. Make Alex push a commit:

   ```
   bash ../teammate.sh
   ```

3. Check again:

   ```
   git status
   ```

   Still "up to date". Git compares `main` with `origin/main`, your local copy of the remote branch, and nothing has updated that copy yet. `git ls-remote origin main` asks the remote itself: a different hash from `git rev-parse main`.

4. Fetch, then look again:

   ```
   git fetch
   git status
   git lg --all
   ```

   Now you're "behind 'origin/main' by 1 commit". Fetch moved `origin/main` to Alex's commit; `main` and your files didn't change.

5. Move `main` up to it:

   ```
   git merge --ff-only origin/main
   ```

Extra: rebuild the Try-it, run `bash ../teammate.sh`, then `git branch -vv` before and after `git fetch`. The `[origin/main: behind 1]` it shows is only as fresh as your last fetch.

## Set up like a pro

### config-origin (3 min)

```
bash lab try config-origin
```

1. List every setting Git sees here, with its scope and the file it comes from:

   ```
   git config --list --show-scope --show-origin
   ```

   `system` lines come from Git's install, `global` from your own `.gitconfig`, `local` from this repo's `.git/config`. When a setting appears more than once, the last one wins. On Windows, `core.autocrlf` often shows up twice: `true` from system, `false` from this repo.

2. This repo sets its own email. See every value of `user.email`:

   ```
   git config --show-scope --show-origin --get-all user.email
   ```

   Your global email (if you set one), then `local file:.git/config sam@work.example.com`.

3. Ask for the value that wins, and who your next commit here would be by:

   ```
   git config user.email
   git var GIT_AUTHOR_IDENT
   ```

Extra: a `-c` on the command line beats every file. Try `git -c user.email=me@example.com config --show-scope user.email`.

### ignore-rules (3 min, if time)

```
bash lab try ignore-rules
```

1. See the files Git is ignoring:

   ```
   git status --ignored
   ```

   `build/` and `server.log` (and `.git-lab-workspace`, the kit's marker file).

2. Ask which rule ignores each one:

   ```
   git check-ignore -v server.log build/app.js
   ```

   Each line is `file:line:pattern`, then the path: `server.log` is ignored by line 2 of `.gitignore`, `*.log`.

3. `debug.log` matches `*.log` too, but Git still tracks it, because it was committed before the rule. Ask about it:

   ```
   git check-ignore -v debug.log
   ```

   No output: ignore rules never apply to tracked files.

4. Stop tracking it, but keep the file on disk:

   ```
   git rm --cached debug.log
   git commit -m "Stop tracking debug.log"
   git check-ignore -v debug.log
   ```

Look for: `debug.log` is still in the folder, `git status` is clean, and step 3's command now names the `*.log` rule.

Extra: `keep.log` matches `*.log` but is committed on purpose. `git check-ignore -v --no-index keep.log` checks it as if it weren't tracked: which rule wins? Then try `git check-ignore -v .git-lab-workspace`: rules can live outside `.gitignore` too.

## Merging vs. rebasing

### pull-rebase (4 min)

```
bash lab try pull-rebase
```

The folder holds the shared remote `origin.git` and your clone `me`. A teammate has pushed a commit you haven't fetched, and you have one commit you haven't pushed. Work from `me`: `cd me`.

1. Pull with a merge:

   ```
   git pull --no-rebase --no-edit
   git lg --all
   ```

   A merge commit, "Merge branch 'main' of ..." (then the practice folder's path), joins your commit and the teammate's.

2. Undo that pull. `ORIG_HEAD` is where `main` was before it:

   ```
   git reset --hard ORIG_HEAD
   ```

3. Pull again, rebasing this time:

   ```
   git pull --rebase
   git lg --all
   ```

Look for: a straight line, with your "Print a receipt" on top of the teammate's "Add shipping cost". Same files as in step 1, no merge commit, but your commit has a new hash.

Extra: which one do you get from a plain `git pull`? `git config --show-origin pull.rebase` tells you (this repo sets it to `false`).

### ff-only (3 min, if time)

```
bash lab try ff-only
```

`docs` is directly ahead of `main`. `feature` branched off earlier, and `main` has moved on since. See it with `git lg --all`.

1. Try to fast-forward `main` to `feature`:

   ```
   git merge --ff-only feature
   ```

   Git refuses: `fatal: Not possible to fast-forward, aborting.` Nothing changed.

2. The same with `docs` works, because `main` only has to move forward:

   ```
   git merge --ff-only docs
   git lg --all
   ```

   "Fast-forward": `main` now points at the same commit as `docs`. No merge commit.

3. Undo that, then merge `docs` again, forcing a merge commit:

   ```
   git reset --hard ORIG_HEAD
   git merge --no-ff --no-edit docs
   git lg --all
   ```

Look for: a "Merge branch 'docs'" commit with two parents. The history now shows that `docs` was a branch, even though a fast-forward was possible.

Extra: `git merge --no-edit feature`. Does it need `--no-ff`?

## Crafting clean history

### add-patch (4 min)

```
bash lab try add-patch
```

`src/price.sh` has uncommitted changes. Stage the tax change (8 to 9) and the shipping fix (`-gt` to `-ge`), but not the currency experiment or the debug line. See them first with `git diff`.

1. Start staging piece by piece:

   ```
   git add -p
   ```

2. The first hunk has the tax and the currency changes together. Split it:

   ```
   s
   ```

3. Git now asks about each of the three parts in turn. Stage the first (the tax change), skip the second (the currency):

   ```
   y
   n
   ```

4. The third prompt is the last hunk: it has the debug line right next to the fix, so `s` isn't offered. Edit it instead:

   ```
   e
   ```

   In the editor, delete the `+  echo "debug: ...` line, save and close the file (in VS Code, close its tab). If nothing opens, or Git carries on at once, set an editor that waits: `git config core.editor "code --wait"`.

5. Check the result:

   ```
   git diff --staged
   git diff
   ```

Look for: staged are only `TAX_PERCENT=9` and `-ge`; `CURRENCY=EUR` and the debug line are still unstaged, and still in the file.

Extra: commit what you staged, then `git stash` the rest. Or press `?` at the `git add -p` prompt to see every answer it takes.

### stash-branch (3 min, if time)

```
bash lab try stash-branch
```

You're halfway through a search feature on `main`: a change to `src/price.sh` and a new file, `src/search.sh`. See it with `git status --short`.

1. Put it all away, the new file included (`-u`):

   ```
   git stash -u -m "half-done search"
   git status --short
   ```

   `git status --short` prints nothing: the working tree is clean.

2. See what the stash holds:

   ```
   git stash list
   git stash show -u
   ```

3. Decide it deserves its own branch. Make one and bring the work back in one go:

   ```
   git stash branch search
   ```

Look for: you're on `search`, both files are back (`src/search.sh` still untracked), and the stash is gone from `git stash list`. The branch starts at the commit you stashed from, so the work applies cleanly even if `main` has moved on since.

Extra: rebuild the Try-it and run plain `git stash`. What does `git status --short` show?

### cherry-pick-hotfix (3 min, if time)

```
bash lab try cherry-pick-hotfix
```

`release/1.0` branched off before `main` got two features and, between them, a fix. Ship only the fix to the release.

1. Find the fix on `main` and copy its hash:

   ```
   git log --oneline main
   ```

2. Switch to the release branch and copy the fix onto it, recording where it came from (`-x`):

   ```
   git switch release/1.0
   git cherry-pick -x <hash-of-Fix-tax-rounding>
   ```

3. Look at the new commit and the graph:

   ```
   git log -1
   git lg --all
   ```

Look for: the message ends with `(cherry picked from commit <hash>)`. "Fix tax rounding" is now on both branches with different hashes, and "Print a receipt" and "Add search" stayed on `main`.

Extra: `git cherry -v main` checks each release commit against `main`: `+` means `main` has no such change. Which line starts with `-`, and why?

## Undo almost anything

### reset-modes (4 min)

```
bash lab try reset-modes
```

The last commit, "Add a 10% discount", adds one line to `src/price.sh`. Undo it three ways and watch where the change ends up. After each reset, `ORIG_HEAD` is where `main` was before it.

1. `--soft` moves the branch only. The change is still staged:

   ```
   git reset --soft HEAD~1
   git status --short
   ```

   `M  src/price.sh` (the `M` in the first column means staged). Put the commit back:

   ```
   git reset --hard ORIG_HEAD
   ```

2. `--mixed` (the default) also resets the staging area. The change is still in the file, unstaged:

   ```
   git reset HEAD~1
   git status --short
   ```

   ` M src/price.sh` (the `M` in the second column). Put it back again:

   ```
   git reset --hard ORIG_HEAD
   ```

3. `--hard` resets the files too. The change is gone from disk:

   ```
   git reset --hard HEAD~1
   git status --short
   cat src/price.sh
   ```

   `git status` prints nothing (the reset itself prints "HEAD is now at ..."), and there's no `DISCOUNT_PERCENT` line.

4. Even that is recoverable, because the commit still exists:

   ```
   git reset --hard ORIG_HEAD
   git lg
   ```

Extra: `--hard` can't bring back changes you never committed. Edit `README.md`, run `git reset --hard`, and check `git reflog`: is your edit anywhere?

### reflog-rescue (3 min, if time)

```
bash lab try reflog-rescue
```

`experiment` has two commits that aren't on `main`. See them with `git lg --all`.

1. Delete the branch, as if by accident:

   ```
   git branch -D experiment
   ```

   `git lg --all` no longer shows its commits.

2. Look at where HEAD has been:

   ```
   git reflog
   ```

   Find `commit: Limit coupons to one per order`, the last commit made on `experiment`. Its name is on the same line: `HEAD@{2}`.

3. Put a branch back on it:

   ```
   git branch experiment HEAD@{2}
   git lg --all
   ```

Look for: `experiment` is back with both commits, "Try coupons" and "Limit coupons to one per order".

Extra: after step 3, `git reflog experiment` shows only one entry. Deleting a branch deletes its own reflog; it was HEAD's reflog that saved you. And `git branch -D` printed the hash too (`was <hash>`): `git branch experiment <hash>` works as well.

### revert (2 min, if time)

```
bash lab try revert
```

The folder holds the shared remote `origin.git` and your clone `me`. Everything is pushed, including "Update tax", which set the tax to 80%. Work from `me`: `cd me`.

1. Make a new commit that undoes it:

   ```
   git revert --no-edit HEAD~1
   ```

2. Look at what revert made:

   ```
   git show
   ```

   The message says `This reverts commit <hash>.` and the diff puts `TAX_PERCENT=8` back.

3. Share it the normal way:

   ```
   git push
   git lg
   ```

Look for: "Update tax" is still in the history, with the revert on top. Nothing was rewritten, so nobody needs to force-push or re-clone.

Extra: revert the revert (`git revert --no-edit HEAD`). What does `src/price.sh` say now?

## Rebase workflows with Bitbucket

### squash-merged (2 min, if time)

```
bash lab try squash-merged
```

`feature` has two commits. You'll play the server: Bitbucket's "Squash" merge strategy puts all of a branch's changes on `main` as one new commit.

1. Squash-merge `feature` into `main`, the way the server would:

   ```
   git merge --squash feature
   git commit -m "Add discounts (#12)"
   ```

2. The work is on `main` now, so delete the branch:

   ```
   git branch -d feature
   ```

   Git refuses: the branch is "not fully merged". `-d` only checks commits, and `feature`'s two commits aren't on `main`. The squash commit is a new commit with the same changes.

3. See the commits Git is worried about, then check that their changes really are on `main`:

   ```
   git log --oneline main..feature
   git diff main feature
   ```

   The log shows both commits; the diff shows nothing, so `main` already has everything `feature` has.

4. Now it's safe to force the delete:

   ```
   git branch -D feature
   ```

   Use `-D` only after a check like step 3. Deleted the wrong branch? Git printed its last commit ("was ..."): `git branch feature <hash>` brings it back.

Extra: build it again, add a commit to `feature` after the squash, then run step 3. What does the diff show now, and would `-D` be safe?

## Submodules

### submodule-bump (8 min)

```
bash lab try submodule-bump
```

Two folder remotes: `lib.git`, a small library with versions `v1.0` and `v1.1`, and `app.git`, which has `lib` as a submodule pinned to `v1.0`.

1. Clone the app and its submodule in one go:

   ```
   git -c protocol.file.allow=always clone --recurse-submodules app.git app
   ```

   The `-c protocol.file.allow=always` is only needed because these remotes are local folders: Git blocks submodules from folders by default. You won't need it with Bitbucket.

2. See which `lib` commit the app uses, and the state inside the submodule:

   ```
   cd app
   git submodule status
   git -C lib status
   ```

   The app records one exact commit (`v1.0`), so Git checks it out as a detached HEAD.

3. Move `lib` to a new version: get on its `main` (that's `v1.1`) and add a fix of your own:

   ```
   cd lib
   git switch main
   echo 'round_dollars() { echo $(( ($1 + 50) / 100 * 100 )); }' >> round.sh
   git commit -am "Add round_dollars"
   cd ..
   ```

4. The app sees the submodule moved. Commit the new pointer like any change:

   ```
   git status
   git diff --submodule=log
   git add lib
   git commit -m "Use lib with round_dollars"
   ```

   `status` says `modified: lib (new commits)`; the diff lists the lib commits you're about to point at.

5. Try to push the app first:

   ```
   git push --recurse-submodules=check
   ```

   Refused: your `lib` commit is on no remote yet, so anyone who pulled the app would get a pointer to a commit they can't fetch.

6. Push in the right order, library first:

   ```
   git -C lib push
   git push
   ```

Extra: make another `lib` change, commit the pointer, and push with `git push --recurse-submodules=on-demand`. Git pushes `lib` first, then the app. Check with a fresh clone: `git -c protocol.file.allow=always clone --recurse-submodules app.git check`.

### submodule-trap (3 min, if time)

```
bash lab try submodule-trap
```

`app` is a clone with a `lib` submodule. Someone made a commit inside `lib` and never pushed it. Find it before it's lost.

1. Look from the app:

   ```
   cd app
   git status
   git submodule status
   ```

   `status` says `modified: lib (new commits)`. The `+` in front of the submodule's hash means `lib` is on a different commit than the one the app records. The name in brackets, like `heads/main-1-g...`, is `git describe` for that commit: one commit after `main`.

2. See which commits:

   ```
   git diff --submodule=log
   ```

3. Look inside the submodule:

   ```
   cd lib
   git status
   git log --oneline origin/main..HEAD
   ```

   `HEAD detached from ...`: there's no branch here, because a submodule checkout always starts detached. The log shows the commit that is on no remote. If you switched to `main` now, Git would warn that you're leaving it behind.

4. Put it on a branch and push it, so it's safe:

   ```
   git switch -c round-dollars
   git push -u origin round-dollars
   ```

Extra: in `app`, run `git config status.submoduleSummary true`, then `git status`. It now lists the submodule's commits too, which makes this trap easier to spot every day.

## Finding when and why things changed

### history-search (5 min)

```
bash lab try history-search
```

1. Find the commit that added the free shipping limit. `-S` lists commits that change how many times the text appears:

   ```
   git log -S FREE_SHIPPING_OVER --oneline
   ```

   Only "Add shipping costs". Add `-p` to see the line arrive in the diff.

2. The limit was changed later, but that commit didn't add or remove the text, so `-S` skipped it. `-G` lists every commit whose diff has a line matching the text (a regular expression):

   ```
   git log -G FREE_SHIPPING_OVER --oneline
   ```

   Now "Raise the free shipping limit" shows up too.

3. Two dots: commits on `feature` that aren't on `main`:

   ```
   git log --oneline main..feature
   ```

   The three loyalty commits. Swap the names (`feature..main`) to see the two tax commits instead.

4. Three dots: commits on either side, but not on both:

   ```
   git log --oneline --left-right main...feature
   ```

   All five: `<` marks the ones only on `main`, `>` the ones only on `feature`.

Extra: for `git diff` the dots mean something else. Compare `git diff --stat main...feature` (only `feature`'s changes since it branched, like a pull request shows) with `git diff --stat main feature` (the two snapshots, so `main`'s tax changes show up reversed).

### rerere (5 min)

```
bash lab try rerere
```

You're on `feature`, which changes the same line as `main`. rerere ("reuse recorded resolution") remembers how you fixed a conflict and replays it the next time the same conflict appears, for example when you rebase a long-lived branch again.

1. Turn it on for this repo:

   ```
   git config rerere.enabled true
   ```

2. Rebase and hit the conflict. Near the end of the output Git says `Recorded preimage for 'greeting.txt'`:

   ```
   git rebase main
   ```

3. Resolve it in VS Code or any editor: make the first line `Welcome to our shop, friend.` and delete the markers. Then:

   ```
   git add greeting.txt
   git rebase --continue
   ```

   Git says `Recorded resolution for 'greeting.txt'.`

4. Pretend you have to do it again: undo the rebase and repeat it.

   ```
   git reset --hard ORIG_HEAD
   git rebase main
   ```

   Same conflict, but Git says `Resolved 'greeting.txt' using previous resolution.` and the file already has your fix. Check it, then `git add greeting.txt` and `git rebase --continue`.

Extra: `git config rerere.autoUpdate true` stages replayed resolutions for you, and `git rerere forget greeting.txt` drops a resolution you got wrong.

### blame-reformat (3 min, if time)

```
bash lab try blame-reformat
```

Alex wrote `src/price.sh`. Sam then re-indented it (whitespace only) and moved `discount()` to its own file.

1. Blame the file:

   ```
   git blame src/price.sh
   ```

   The re-indented lines (2-4) all point at Sam's "Reformat with 4-space indent" commit, which isn't the commit you want.

2. Ignore whitespace changes:

   ```
   git blame -w src/price.sh
   ```

   Every line is Alex's now (`^` marks the first commit in the history).

3. Blame the moved function, first plainly, then following moved lines:

   ```
   git blame src/discount.sh
   git blame -w -C -C src/discount.sh
   ```

   The first says Sam wrote it all in the move commit. The second finds the lines in `src/price.sh` and shows Alex. `-C` looks for lines moved from files changed in the same commit; `-C -C` also searches the other files of the commit that created the file.

4. Skip the reformat for everyone, without `-w`: list it in an ignore file and point Git at it:

   ```
   git log --format=%H --grep=Reformat > .git-blame-ignore-revs
   git config blame.ignoreRevsFile .git-blame-ignore-revs
   git blame src/price.sh
   ```

   Plain `blame` shows Alex now. Teams commit `.git-blame-ignore-revs` to the repo; each person (or the setup script) runs the `git config` line once.

Extra: run `git config blame.markIgnoredLines true` and blame again. A `?` marks lines that Git moved past an ignored commit (here it shows as `^?`: the `^` means those lines come from the very first commit).

## Parallel work and large repositories

### worktree-hotfix (5 min)

```
bash lab try worktree-hotfix
```

The repo is in `shop`. You're halfway through a change on `feature` when an urgent bug comes in: the tax rate on `main` is 80 instead of 8.

1. Look at your unfinished work:

   ```
   cd shop
   git status
   ```

   `src/receipt.sh` is modified and not committed. No need to stash or commit it.

2. Make a second working folder for the hotfix, on a new branch from `main`:

   ```
   git worktree add -b hotfix ../hotfix main
   ```

3. Fix the bug there and commit:

   ```
   cd ../hotfix
   echo "TAX_PERCENT=8" > src/tax.sh
   git commit -am "Fix the tax rate"
   ```

4. Go back. Your change is untouched, and the hotfix commit is already in this repo (worktrees share one `.git`):

   ```
   cd ../shop
   git status --short
   git worktree list
   git log --oneline -1 hotfix
   ```

5. Remove the extra folder when you're done. The `hotfix` branch stays:

   ```
   git worktree remove ../hotfix
   git branch
   ```

Extra: try `git worktree add ../again feature`. Git refuses: a branch can be checked out in only one worktree at a time.

### sparse-checkout (3 min, if time)

```
bash lab try sparse-checkout
```

A small monorepo: `web`, `api`, `mobile` and `docs` side by side.

1. Keep only the folders you work on (cone mode is the default):

   ```
   git sparse-checkout set api docs
   ls
   ```

   `web` and `mobile` are gone from disk. Files at the top level, like `README.md`, always stay.

2. Ask Git what's going on:

   ```
   git sparse-checkout list
   git status
   ```

   `status` says you're in a sparse checkout with 56% of tracked files present. Nothing was deleted from history: the other files are still in every commit.

3. Add part of a folder:

   ```
   git sparse-checkout add web/css
   ls web
   ```

   You get `web/css`, and also `web/index.html`: cone mode always includes the files directly inside each parent folder.

4. Get everything back:

   ```
   git sparse-checkout disable
   ls
   ```

Extra: run `git sparse-checkout set api docs` again, then `git ls-files -t`. Every file is still tracked; `H` means it's on disk, `S` means sparse checkout skipped it.

## Automating with hooks

### commit-msg-hook (10 min)

```
bash lab try commit-msg-hook
```

The repo has a shared hook in `.githooks/commit-msg`, committed like any other file.

1. Read the hook, and see how Git stored it:

   ```
   cat .githooks/commit-msg
   git ls-files -s .githooks
   ```

   It's a plain `sh` script: Git passes it the message file, and a non-zero exit stops the commit. Mode `100755` means it was committed as executable, so it can run on macOS and Linux after a clone. (Git for Windows ignores that bit and runs any hook file that starts with `#!`.)

2. Git doesn't run it yet. Hooks run only from the `core.hooksPath` folder (`.git/hooks` unless you change it), and cloning never turns hooks on for you. Point this repo at the shared folder:

   ```
   git config core.hooksPath .githooks
   ```

   `core.hooksPath` replaces the hooks folder, it doesn't add one: any hooks from your own global `core.hooksPath` stop running in this repo. (The kit already set this repo's `core.hooksPath` to `.git/hooks`, so your global hooks weren't running here before either.)

3. Commit without a ticket key:

   ```
   echo "Free shipping over 50" >> notes.txt
   git commit -am "Add free shipping idea"
   ```

   The hook prints its message and the commit doesn't happen. `git status` shows your change is still there.

4. Add a key and commit again:

   ```
   git commit -am "PROJ-42 Add free shipping idea"
   ```

5. Skip the hook for one commit:

   ```
   echo "Gift cards" >> notes.txt
   git commit -am "Add gift cards idea" --no-verify
   git log --oneline
   ```

   `--no-verify` skips `commit-msg` (and `pre-commit`). So a hook is a convenience: a rule that must always hold also needs a check on the server.

Extra: make the hook also reject a message whose first line is longer than 72 characters, then test it. Your edit takes effect right away; no need to run `git config` again.

## History cleanup, strategies and structure

### patch-series (4 min, if time)

```
bash lab try patch-series
```

`shop` has a `feature` branch with two commits. `offline` is a copy of `shop`'s `main` with no remote, like a repo on a network you can't push to.

1. Turn the two commits into patch files:

   ```
   cd shop
   git log --oneline main..feature
   git format-patch main..feature -o ../patches
   ```

   One file per commit, numbered in order. Open one: it's an email with the author, date, message and diff.

2. Apply them in the other repo:

   ```
   cd ../offline
   git am ../patches/*.patch
   ```

3. Compare the commits on both sides:

   ```
   git log --oneline -3
   git -C ../shop log --oneline -3 feature
   ```

   Same messages, same changes, different hashes for the two new commits.

4. See why:

   ```
   git log --format=fuller -1
   ```

   The author and author date came from the patch. The committer is you, and the commit date is now, so the commit object is different and so is its hash.

Extra: from `offline`, run `git show HEAD | git patch-id` and `git -C ../shop show feature | git patch-id`. The first column (the patch ID) matches, the second (the commit) doesn't: `patch-id` hashes only the change, so it spots the same change even when the hashes differ. Rebase and `git cherry` use it to skip changes that are already there.

### bundle (4 min, if time)

```
bash lab try bundle
```

A bundle is a whole repo, or just some new commits, in one file you can carry on a USB stick or attach to a ticket.

1. Put all of `main` in a bundle and check it:

   ```
   cd shop
   git bundle create ../shop.bundle main
   git bundle verify ../shop.bundle
   ```

   `verify` lists the ref inside, says the bundle "records a complete history", and that it's okay.

2. Clone a new repo from the file, as if on the other side of an air gap:

   ```
   cd ..
   git clone -b main shop.bundle offline
   git -C offline log --oneline -1
   git -C shop log --oneline -1
   ```

   Same hash on both sides: a bundle carries the commit objects themselves, so nothing is rewritten. (Without `-b main` the clone has no branch to check out, because this bundle doesn't include `HEAD`.)

3. Make a new commit in `shop`, then bundle only that commit:

   ```
   cd shop
   echo "Free shipping over 50." >> README.md
   git commit -am "Add free shipping"
   git bundle create ../update.bundle main~1..main
   ```

4. Check it from the other repo, then fetch from it:

   ```
   cd ../offline
   git bundle verify ../update.bundle
   git fetch ../update.bundle main
   git merge --ff-only FETCH_HEAD
   git log --oneline -2
   ```

   `verify` shows the commit the bundle "requires": the receiving repo must already have it. The new commit arrives with the same hash it has in `shop`.

Extra: run `git init ../empty`, then `git -C ../empty bundle verify ../update.bundle`. It fails: an incremental bundle is no use to a repo that lacks its prerequisite commit.
