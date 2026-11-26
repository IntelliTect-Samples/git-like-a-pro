# Try-its

Short exercises during the talk, 2-10 minutes each. Every Try-it builds its own small repo, so you can do any of them at any time and in any order. Build one, then `cd` into the folder it prints.

Stuck or out of time? Skip it, because nothing later depends on it. The ones marked "(if time)" are ones the class may skip, and they make good practice afterwards.

This file is generated from `try/parts/` by `bash tests/build-try-readme.sh`, so edit the parts and not this file.

## Playground

```
bash lab play
```

A small repo with a few commits on `main` and a `feature` branch. Experiment freely, and run the command again whenever you want to reset it.

## How Git really works

### peek-inside (4 min)

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

### detach-and-return (4 min)

```
bash lab try detach-and-return
```

1. Check out an older commit directly instead of a branch:

   ```
   git switch --detach HEAD~1
   ```

   `git status` now says `HEAD detached at <hash>`.

2. Make a commit there:

   ```
   echo "FREE_SHIPPING_FROM=5000" >> src/price.sh
   git commit -am "Try free shipping"
   ```

3. Go back to `main` and read the warning. Git tells you you're leaving 1 commit behind and prints its hash.

   ```
   git switch main
   ```

4. `git lg --all` no longer shows "Try free shipping", because no branch points to it. Give it one. `HEAD@{1}` means "where HEAD was one move ago":

   ```
   git branch free-shipping HEAD@{1}
   git lg --all
   ```

You should see `free-shipping` branching off "Add price settings", next to `main`.

Running `git switch -c <name>` while detached keeps the commits too. Try it with `git switch --detach main`, commit something, then `git switch -c keep-it`.

### folder-remote (4 min)

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

### same-blob (2 min, if time)

```
bash lab try same-blob
```

1. List every file in the latest commit with its blob hash:

   ```
   git ls-tree -r HEAD
   ```

   `LICENSE.txt` and `docs/LICENSE.txt` have the same hash. Same content means one blob.

2. Count the objects in the repo:

   ```
   git count-objects -v
   ```

   It reports `count: 5`. That's 1 commit, 2 trees (the root and `docs`) and 2 blobs for 3 files.

3. Hash the file yourself. Git hashes only the content, because the file name lives in the tree:

   ```
   git hash-object LICENSE.txt
   ```

Extra: copy a file under a new name and stage it with `cp README.md notes.md` and `git add notes.md`. Does `git count-objects -v` go up? It doesn't, since the content is the same and so is the blob. Only the tree you'd commit next would be new.

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

   `try-this` is only a name for a commit, so you get `commit`. `v1.0` is an object of its own, so you get `tag`.

4. Look inside the tag object:

   ```
   git cat-file -p v1.0
   ```

   It records the commit it points to, the tag name, who tagged it and when (that's you, just now), and the message.

Now run `git describe`, then `git describe --tags`. Why does the first one skip `try-this`? Plain `describe` uses only annotated tags, so it prints something like `v1.0-1-g<hash>`, meaning one commit after v1.0.

### tracking (3 min)

```
bash lab try tracking
```

The folder holds the shared remote `origin.git`, your clone `me` and your teammate Alex's clone `teammate`. Do everything from `me`, so start with `cd me`.

1. Check where you stand:

   ```
   git status
   ```

   It says "Your branch is up to date with 'origin/main'."

2. Make Alex push a commit:

   ```
   bash ../teammate.sh
   ```

3. Check again:

   ```
   git status
   ```

   Still "up to date". Git compares `main` with `origin/main`, which is your local copy of the remote branch, and nothing has updated that copy yet. `git ls-remote origin main` asks the remote itself, and it shows a different hash from `git rev-parse main`.

4. Fetch, then look again:

   ```
   git fetch
   git status
   git lg --all
   ```

   Now you're "behind 'origin/main' by 1 commit". Fetch moved `origin/main` to Alex's commit, but `main` and your files didn't change.

5. Move `main` up to it:

   ```
   git merge --ff-only origin/main
   ```

Extra: rebuild the Try-it, run `bash ../teammate.sh`, and compare `git branch -vv` before and after `git fetch`. The `[origin/main: behind 1]` it shows is only as fresh as your last fetch.

## Set up like a pro

### config-origin (3 min)

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

### ignore-rules (3 min, if time)

```
bash lab try ignore-rules
```

1. See the files Git is ignoring:

   ```
   git status --ignored
   ```

   You'll see `build/` and `server.log`, plus `.git-lab-workspace`, the kit's marker file.

2. Ask which rule ignores each one:

   ```
   git check-ignore -v server.log build/app.js
   ```

   Each line gives `file:line:pattern` and then the path. So `server.log` is ignored by line 2 of `.gitignore`, which is `*.log`.

3. `debug.log` matches `*.log` too, but Git still tracks it, because it was committed before the rule. Ask about it:

   ```
   git check-ignore -v debug.log
   ```

   No output. Ignore rules never apply to tracked files.

4. Stop tracking it, but keep the file on disk:

   ```
   git rm --cached debug.log
   git commit -m "Stop tracking debug.log"
   git check-ignore -v debug.log
   ```

Afterwards `debug.log` is still in the folder, `git status` is clean, and the command from step 3 now names the `*.log` rule.

Extra: `keep.log` matches `*.log` but was committed on purpose. `git check-ignore -v --no-index keep.log` checks it as if it weren't tracked. Which rule wins? Then try `git check-ignore -v .git-lab-workspace` to see that rules can live outside `.gitignore` too.

## Merging vs. rebasing

### pull-rebase (4 min)

```
bash lab try pull-rebase
```

The folder holds the shared remote `origin.git` and your clone `me`. A teammate has pushed a commit you haven't fetched, and you have one commit you haven't pushed. You'll work from `me`, so start with `cd me`.

1. Pull with a merge:

   ```
   git pull --no-rebase --no-edit
   git lg --all
   ```

   You get a merge commit, "Merge branch 'main' of ..." followed by the practice folder's path, joining your commit and the teammate's.

2. Undo that pull. `ORIG_HEAD` is where `main` was before it:

   ```
   git reset --hard ORIG_HEAD
   ```

3. Pull again, rebasing this time:

   ```
   git pull --rebase
   git lg --all
   ```

Now the history is a straight line, with your "Print a receipt" on top of the teammate's "Add shipping cost". The files match step 1 and there's no merge commit, but your commit has a new hash.

Which one does a plain `git pull` give you? `git config --show-origin pull.rebase` will tell you. This repo sets it to `false`.

### ff-only (3 min, if time)

```
bash lab try ff-only
```

`docs` is directly ahead of `main`. `feature` branched off earlier, and `main` has moved on since then. `git lg --all` shows the picture.

1. Try to fast-forward `main` to `feature`:

   ```
   git merge --ff-only feature
   ```

   Git refuses with `fatal: Not possible to fast-forward, aborting.` and nothing changes.

2. The same with `docs` works, because `main` only has to move forward:

   ```
   git merge --ff-only docs
   git lg --all
   ```

   Git reports "Fast-forward". `main` now points at the same commit as `docs`, and there's no merge commit.

3. Undo that, then merge `docs` again, forcing a merge commit:

   ```
   git reset --hard ORIG_HEAD
   git merge --no-ff --no-edit docs
   git lg --all
   ```

This time there's a "Merge branch 'docs'" commit with two parents. The history now records that `docs` was a branch, even though a fast-forward was possible.

Now try `git merge --no-edit feature`. Does it need `--no-ff`?

## Crafting clean history

### add-patch (4 min)

```
bash lab try add-patch
```

`src/price.sh` has uncommitted changes. Stage the tax change (8 to 9) and the shipping fix (`-gt` to `-ge`), but not the currency experiment or the debug line. Run `git diff` first to see them.

1. Start staging piece by piece:

   ```
   git add -p
   ```

2. The first hunk has the tax and the currency changes together. Split it:

   ```
   s
   ```

3. Git now asks about each of the three parts in turn. Stage the first one, the tax change, and skip the second, the currency:

   ```
   y
   n
   ```

4. The third prompt is the last hunk. The debug line sits right next to the fix, so `s` isn't offered. Edit it instead:

   ```
   e
   ```

   In the editor, delete the `+  echo "debug: ...` line, then save and close the file. In VS Code that means closing its tab. If nothing opens, or Git carries on at once, set an editor that waits: `git config core.editor "code --wait"`.

5. Check the result:

   ```
   git diff --staged
   git diff
   ```

Only `TAX_PERCENT=9` and `-ge` should be staged. `CURRENCY=EUR` and the debug line stay unstaged, and they're still in the file.

If you have time, commit what you staged and `git stash` the rest. You can also press `?` at the `git add -p` prompt to see every answer it takes.

### stash-branch (3 min, if time)

```
bash lab try stash-branch
```

You're halfway through a search feature on `main`, with a change to `src/price.sh` and a new file, `src/search.sh`. `git status --short` shows both.

1. Put it all away. The `-u` takes the new file along too:

   ```
   git stash -u -m "half-done search"
   git status --short
   ```

   `git status --short` prints nothing now, so the working tree is clean.

2. See what the stash holds:

   ```
   git stash list
   git stash show -u
   ```

3. You decide it deserves its own branch. Make one and bring the work back in one go:

   ```
   git stash branch search
   ```

You should be on `search` with both files back, `src/search.sh` still untracked, and the stash gone from `git stash list`. The branch starts at the commit you stashed from, so the work applies cleanly even if `main` has moved on since.

For comparison, rebuild the Try-it and run plain `git stash`. What does `git status --short` show?

### cherry-pick-hotfix (3 min, if time)

```
bash lab try cherry-pick-hotfix
```

`release/1.0` branched off before `main` got two features, with a fix landing between them. Ship only the fix to the release.

1. Find the fix on `main` and copy its hash:

   ```
   git log --oneline main
   ```

2. Switch to the release branch and copy the fix onto it. The `-x` records where it came from:

   ```
   git switch release/1.0
   git cherry-pick -x <hash-of-Fix-tax-rounding>
   ```

3. Look at the new commit and the graph:

   ```
   git log -1
   git lg --all
   ```

The message should end with `(cherry picked from commit <hash>)`. "Fix tax rounding" is now on both branches with different hashes, while "Print a receipt" and "Add search" stayed on `main`.

Extra: `git cherry -v main` checks each release commit against `main`, and a `+` means `main` has no such change. Which line starts with `-`, and why?

## Undo almost anything

### reset-modes (4 min)

```
bash lab try reset-modes
```

The last commit, "Add a 10% discount", adds one line to `src/price.sh`. Undo it three ways and watch where the change ends up. After each reset, `ORIG_HEAD` is where `main` was before it.

1. `--soft` moves only the branch, so the change is still staged:

   ```
   git reset --soft HEAD~1
   git status --short
   ```

   You'll see `M  src/price.sh`. An `M` in the first column means staged. Put the commit back:

   ```
   git reset --hard ORIG_HEAD
   ```

2. `--mixed`, the default, also resets the staging area. The change is still in the file, but unstaged:

   ```
   git reset HEAD~1
   git status --short
   ```

   This time it's ` M src/price.sh`, with the `M` in the second column. Put it back again:

   ```
   git reset --hard ORIG_HEAD
   ```

3. `--hard` resets the files too, and the change is gone from disk:

   ```
   git reset --hard HEAD~1
   git status --short
   cat src/price.sh
   ```

   The reset prints "HEAD is now at ...", `git status` prints nothing, and there's no `DISCOUNT_PERCENT` line in the file.

4. Even that is recoverable, because the commit still exists:

   ```
   git reset --hard ORIG_HEAD
   git lg
   ```

Extra: `--hard` can't bring back changes you never committed. Edit `README.md`, run `git reset --hard`, and check `git reflog`. Is your edit anywhere?

### reflog-rescue (3 min, if time)

```
bash lab try reflog-rescue
```

`experiment` has two commits that aren't on `main`. You can see them with `git lg --all`.

1. Delete the branch, as if by accident:

   ```
   git branch -D experiment
   ```

   `git lg --all` no longer shows its commits.

2. Look at where HEAD has been:

   ```
   git reflog
   ```

   Find `commit: Limit coupons to one per order`, the last commit made on `experiment`. Its name, `HEAD@{2}`, is on the same line.

3. Put a branch back on it:

   ```
   git branch experiment HEAD@{2}
   git lg --all
   ```

`experiment` should be back with both commits, "Try coupons" and "Limit coupons to one per order".

Extra: run `git reflog experiment` now and it shows only one entry. Deleting a branch deletes its own reflog too, so it was HEAD's reflog that saved you. `git branch -D` also printed the hash (`was <hash>`), and `git branch experiment <hash>` works as well.

### revert (2 min, if time)

```
bash lab try revert
```

The folder holds the shared remote `origin.git` and your clone `me`. Everything is pushed, including "Update tax", which set the tax to 80%. You'll work from `me`, so `cd me` first.

1. Make a new commit that undoes it:

   ```
   git revert --no-edit HEAD~1
   ```

2. Look at what revert made:

   ```
   git show
   ```

   The message says `This reverts commit <hash>.`, and the diff puts `TAX_PERCENT=8` back.

3. Share it the normal way:

   ```
   git push
   git lg
   ```

"Update tax" is still in the history, with the revert on top of it. Nothing was rewritten, so nobody has to force-push or re-clone.

For one more round, revert the revert with `git revert --no-edit HEAD`. What does `src/price.sh` say now?

## Rebase workflows with Bitbucket

### squash-merged (2 min, if time)

```
bash lab try squash-merged
```

`feature` has two commits. You'll play the server here. Bitbucket's "Squash" merge strategy puts all of a branch's changes on `main` as one new commit.

1. Squash-merge `feature` into `main`, the way the server would:

   ```
   git merge --squash feature
   git commit -m "Add discounts (#12)"
   ```

2. The work is on `main` now, so delete the branch:

   ```
   git branch -d feature
   ```

   Git refuses because the branch is "not fully merged". `-d` only checks commits, and `feature`'s two commits aren't on `main`. The squash commit is a new commit that carries the same changes.

3. See the commits Git is worried about, then check that their changes really are on `main`:

   ```
   git log --oneline main..feature
   git diff main feature
   ```

   The log shows both commits, but the diff is empty, so `main` already has everything `feature` has.

4. Now it's safe to force the delete:

   ```
   git branch -D feature
   ```

   Only reach for `-D` after a check like step 3. If you delete the wrong branch, look for the last commit Git printed ("was ...") and run `git branch feature <hash>` to bring it back.

Extra: build it again, add a commit to `feature` after the squash, and repeat step 3. What does the diff show now, and would `-D` still be safe?

## Submodules

### submodule-bump (8 min)

```
bash lab try submodule-bump
```

There are two folder remotes. `lib.git` is a small library with versions `v1.0` and `v1.1`, and `app.git` has `lib` as a submodule pinned to `v1.0`.

1. Clone the app and its submodule in one go:

   ```
   git -c protocol.file.allow=always clone --recurse-submodules app.git app
   ```

   You need `-c protocol.file.allow=always` here only because these remotes are local folders, and Git blocks submodules from folders by default. With Bitbucket you won't need it.

2. See which `lib` commit the app uses, and the state inside the submodule:

   ```
   cd app
   git submodule status
   git -C lib status
   ```

   The app records one exact commit (`v1.0`), so Git checks it out as a detached HEAD.

3. Move `lib` to a new version. Get on its `main`, which is `v1.1`, and add a fix of your own:

   ```
   cd lib
   git switch main
   echo 'round_dollars() { echo $(( ($1 + 50) / 100 * 100 )); }' >> round.sh
   git commit -am "Add round_dollars"
   cd ..
   ```

   On Windows you may see "LF will be replaced by CRLF". That comes from Git for Windows' line-ending setting and is harmless.

4. The app notices the submodule moved. Commit the new pointer like any other change:

   ```
   git status
   git diff --submodule=log
   git add lib
   git commit -m "Use lib with round_dollars"
   ```

   `status` says `modified: lib (new commits)`, and the diff lists the lib commits you're about to point at.

5. Try to push the app first:

   ```
   git push --recurse-submodules=check
   ```

   Git refuses. Your `lib` commit isn't on any remote yet, so anyone who pulled the app would get a pointer to a commit they can't fetch.

6. Push in the right order, library first:

   ```
   git -C lib push
   git push
   ```

Extra: make another `lib` change, commit the pointer, and push with `git push --recurse-submodules=on-demand`. Git pushes `lib` first, then the app. To confirm, make a fresh clone with `git -c protocol.file.allow=always clone --recurse-submodules app.git check`.

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

   `status` says `modified: lib (new commits)`. The `+` in front of the submodule's hash means `lib` is on a different commit than the one the app records. The name in brackets, like `heads/main-1-g...`, is `git describe` for that commit, so it's one commit after `main`.

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

   You'll see `HEAD detached from ...`. There's no branch here, because a submodule checkout always starts detached. The log shows the commit that isn't on any remote, and if you switched to `main` now, Git would warn that you're leaving it behind.

4. Put it on a branch and push it so it's safe:

   ```
   git switch -c round-dollars
   git push -u origin round-dollars
   ```

To make this trap easier to spot day to day, run `git config status.submoduleSummary true` in `app`, then `git status`. It now lists the submodule's commits as well.

## Finding when and why things changed

### history-search (5 min)

```
bash lab try history-search
```

1. Find the commit that added the free shipping limit. `-S` lists the commits that change how many times the text appears:

   ```
   git log -S FREE_SHIPPING_OVER --oneline
   ```

   You get only "Add shipping costs". Add `-p` to watch the line arrive in the diff.

2. The limit was changed later, but that commit didn't add or remove the text, so `-S` skipped it. `-G` lists every commit whose diff has a line matching the text, which it treats as a regular expression:

   ```
   git log -G FREE_SHIPPING_OVER --oneline
   ```

   Now "Raise the free shipping limit" shows up too.

3. Two dots give you the commits on `feature` that aren't on `main`:

   ```
   git log --oneline main..feature
   ```

   That's the three loyalty commits. Swap the names (`feature..main`) and you get the two tax commits instead.

4. Three dots give the commits on either side, but not on both:

   ```
   git log --oneline --left-right main...feature
   ```

   All five appear. `<` marks the ones only on `main` and `>` the ones only on `feature`.

Extra: `git diff` reads the dots differently. Compare `git diff --stat main...feature`, which shows only `feature`'s changes since it branched (what a pull request shows), with `git diff --stat main feature`, which compares the two snapshots so `main`'s tax changes show up reversed.

### rerere (5 min)

```
bash lab try rerere
```

You're on `feature`, which changes the same line as `main`. rerere ("reuse recorded resolution") remembers how you fixed a conflict and replays that fix the next time the same conflict shows up, say when you rebase a long-lived branch again.

1. Turn it on for this repo:

   ```
   git config rerere.enabled true
   ```

2. Rebase and run into the conflict. Watch for `Recorded preimage for 'greeting.txt'` near the end of the output.

   ```
   git rebase main
   ```

3. Resolve it in VS Code or any editor. Make the first line `Welcome to our shop, friend.`, delete the markers, and then run:

   ```
   git add greeting.txt
   git rebase --continue
   ```

   This time Git says `Recorded resolution for 'greeting.txt'.`

4. Now pretend you have to do it all again. Undo the rebase and repeat it:

   ```
   git reset --hard ORIG_HEAD
   git rebase main
   ```

   It's the same conflict, but Git says `Resolved 'greeting.txt' using previous resolution.` and the file already has your fix. Check it, then `git add greeting.txt` and `git rebase --continue`.

If you want Git to stage replayed resolutions for you, set `git config rerere.autoUpdate true`. And if you recorded a bad fix, `git rerere forget greeting.txt` drops it.

### blame-reformat (3 min, if time)

```
bash lab try blame-reformat
```

Alex wrote `src/price.sh`. Sam then re-indented it, changing only whitespace, and moved `discount()` into its own file.

1. Blame the file:

   ```
   git blame src/price.sh
   ```

   The re-indented lines (2-4) all point at Sam's "Reformat with 4-space indent" commit. That's not the commit you're after.

2. Ignore whitespace changes:

   ```
   git blame -w src/price.sh
   ```

   Now every line is Alex's. The `^` marks the first commit in the history.

3. Blame the moved function, first plainly, then following moved lines:

   ```
   git blame src/discount.sh
   git blame -w -C -C src/discount.sh
   ```

   The first says Sam wrote it all in the move commit. The second finds the lines in `src/price.sh` and shows Alex. One `-C` looks for lines moved from files changed in the same commit, and `-C -C` also searches the other files of the commit that created the file.

4. To skip the reformat for everyone without `-w`, list it in an ignore file and point Git at it:

   ```
   git log --format=%H --grep=Reformat > .git-blame-ignore-revs
   git config blame.ignoreRevsFile .git-blame-ignore-revs
   git blame src/price.sh
   ```

   Plain `blame` shows Alex now. Teams commit `.git-blame-ignore-revs` to the repo, and each person runs the `git config` line once, or a setup script does it for them.

Want more? Run `git config blame.markIgnoredLines true` and blame again. Git puts a `?` on lines it moved past an ignored commit. Here it shows as `^?`, because the `^` means those lines come from the very first commit.

## Parallel work and large repositories

### worktree-hotfix (5 min)

```
bash lab try worktree-hotfix
```

The repo is in `shop`. You're halfway through a change on `feature` when an urgent bug comes in. The tax rate on `main` is 80 instead of 8.

1. Look at your unfinished work:

   ```
   cd shop
   git status
   ```

   `src/receipt.sh` is modified and not committed. You don't need to stash or commit it.

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

4. Go back. Your change is untouched, and the hotfix commit is already in this repo because worktrees share one `.git`:

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

What happens if you try `git worktree add ../again feature`? Git refuses, because a branch can be checked out in only one worktree at a time.

### sparse-checkout (3 min, if time)

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

   It's a plain `sh` script. Git passes it the message file, and a non-zero exit stops the commit. Mode `100755` means it was committed as executable, so it can run on macOS and Linux after a clone. Git for Windows ignores that bit and runs any hook file that starts with `#!`.

2. Git doesn't run it yet. Hooks run only from the `core.hooksPath` folder, which is `.git/hooks` unless you change it, and cloning never turns hooks on for you. Point this repo at the shared folder:

   ```
   git config core.hooksPath .githooks
   ```

   `core.hooksPath` replaces the hooks folder rather than adding one, so any hooks from your own global `core.hooksPath` stop running in this repo. The kit had already set this repo's `core.hooksPath` to `.git/hooks`, so your global hooks weren't running here before either.

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

   `--no-verify` skips `commit-msg` and `pre-commit`. That makes a hook a convenience, not a guarantee. A rule that must always hold also needs a check on the server.

Finished early? Make the hook also reject a message whose first line is longer than 72 characters, then test it. Your edit takes effect right away, so there's no need to run `git config` again.

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

   You get one file per commit, numbered in order. Open one and you'll see it's an email with the author, date, message and diff.

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

   Same messages and same changes, but the two new commits have different hashes.

4. See why:

   ```
   git log --format=fuller -1
   ```

   The author and author date came from the patch. The committer is you and the commit date is now, so the commit object differs and so does its hash.

To go further, run `git show HEAD | git patch-id` from `offline`, then `git -C ../shop show feature | git patch-id`. The first column, the patch ID, matches. The second, the commit, doesn't. `patch-id` hashes only the change, so it spots the same change even when the hashes differ. Rebase and `git cherry` use it to skip changes that are already there.

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

   `verify` lists the ref inside and says the bundle "records a complete history" and is okay.

2. Clone a new repo from the file, as if on the other side of an air gap:

   ```
   cd ..
   git clone -b main shop.bundle offline
   git -C offline log --oneline -1
   git -C shop log --oneline -1
   ```

   You get the same hash on both sides, because a bundle carries the commit objects themselves and nothing is rewritten. Without `-b main` the clone would have no branch to check out, since this bundle doesn't include `HEAD`.

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

   This time `verify` shows the commit the bundle "requires", which the receiving repo must already have. The new commit arrives with the same hash it has in `shop`.

Extra: run `git init ../empty`, then `git -C ../empty bundle verify ../update.bundle`. It fails, because an incremental bundle is no use to a repo that lacks its prerequisite commit.
