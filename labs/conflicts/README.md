# Lab: Conflicts

About 25 minutes. Section: Merging vs. rebasing.

A teammate pushed two commits to `main`: tax is now rounded to the nearest cent, and the README says so. Meanwhile two branches were started from the old `main`:

- `loyalty`: 5% off for loyalty members (two commits)
- `receipt-footer`: a thank-you line at the end of every receipt (one commit)

Both clash with the teammate's work. Bring them into `main` the way many teams do: **rebase** each branch onto `main` first, then merge `loyalty` with a merge commit (`--no-ff`) and fast-forward `receipt-footer`.

## Set up

```
bash lab conflicts
```

Then `cd` into the folder it prints. Start at a later step with `bash lab conflicts --step 2` (or 3). Check your progress from the kit folder with `bash lab conflicts --check`, and get a hint with `bash lab hint conflicts <step>`.

This repo shows conflicts in the **zdiff3** style: between `|||||||` and `=======` you also see the original lines, before either side changed them.

## Look first

```
git lg --all
git diff main...loyalty
bash test.sh
```

`main...loyalty` (three dots) shows only what `loyalty` changed since it branched off.

## Step 1 - Rebase loyalty onto main (about 10 minutes)

```
git switch loyalty
git rebase main
```

Git replays the two `loyalty` commits on top of the teammate's work and stops at each conflict. Expect two stops: `src/price.sh` in the first commit, then `README.md` in the second, after you run `git rebase --continue`.

1. `git status` shows which files conflict.
2. Resolve them so **both** changes survive. In `src/price.sh`, members still get 5% off before tax, and tax is still rounded. In `README.md`, keep both sentences.
   - VS Code: open the file and click **Resolve in Merge Editor**, or edit the markers by hand.
   - Command line: edit the file, then delete every `<<<<<<<`, `|||||||`, `=======` and `>>>>>>>` line.
3. `bash test.sh`, then `git add <file>` and `git rebase --continue`.

Lost? `git rebase --abort` puts the branch back exactly as it was.

## Step 2 - Merge loyalty with a merge commit (about 3 minutes)

```
git switch main
git merge --no-ff loyalty
git lg
```

`loyalty` now sits on top of `main`, so a fast-forward was possible. `--no-ff` makes a merge commit anyway: the feature's commits stay grouped together under it. This is called semi-linear history.

## Step 3 - Fast-forward receipt-footer (about 7 minutes)

1. Try to fast-forward it as it is:

   ```
   git merge --ff-only receipt-footer
   ```

   Git refuses: the branch has diverged from `main`.

2. Rebase it, resolve the conflict in `src/receipt.sh` (keep the member argument **and** the thank-you line), and continue:

   ```
   git switch receipt-footer
   git rebase main
   ```

3. Now the fast-forward works:

   ```
   git switch main
   git merge --ff-only receipt-footer
   git lg
   bash test.sh
   ```

## Stretch

- Rebuild (`bash lab conflicts`) and merge `loyalty` into `main` **without** rebasing first. Same conflicts, but you resolve them once, in the merge commit. Compare `git lg` with your rebased version.
- During a rebase, `git checkout --ours <file>` takes **main's** version and `--theirs` takes **your** commit's version, the opposite of a merge. Rebuild and try both on `README.md` to see it.
- `git log --merges --first-parent main` lists only the features merged into `main`.
- `rebase --onto`: rebuild, then move only the *second* `loyalty` commit onto `main`, leaving the first behind: `git rebase --onto main loyalty~1 loyalty`. Read it as "take the commits after `loyalty~1`, up to `loyalty`, and replay them onto `main`".

## Debrief

- Where did you have to understand the code, not just pick a side?
- What does the merge commit give you that a fast-forward doesn't?
- Why did `receipt-footer` conflict even though nobody else touched its line?
