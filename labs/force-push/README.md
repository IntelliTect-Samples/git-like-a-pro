# Lab: Force push safely

About 25 minutes. Section: Rebase workflows with Bitbucket. Works well in pairs: one types, one predicts what Git will say.

Teams that rebase their pull request branches have to force push: a rebase makes new commits, so the branch on the server is no longer part of yours. This lab is about doing that without ever losing someone else's work.

Everything runs locally:

- `bitbucket.git` stands in for Bitbucket. Like a branch permission, it refuses force pushes and deletes on `main`.
- `me/` is your clone. Your pull request branch is `receipt-totals`.
- `teammate.sh` plays your teammate Alex, who pushes to the same "server" from `alex/`.

## Set up

```
bash lab force-push
cd "<the folder it prints>/me"
```

Start at a later step with `bash lab force-push --step 2` (or 3). Check progress from the kit folder with `bash lab force-push --check`; hints with `bash lab hint force-push <step>`.

## Step 1 - main moved under your pull request (about 8 minutes)

Alex merged something into `main` while your pull request was open. You don't know yet.

1. Look: `git lg --all`. Your `origin/main` is old: you haven't fetched.
2. Fetch and rebase onto the new `main`:

   ```
   git fetch
   git lg --all
   git rebase origin/main
   ```

3. Push the usual way: `git push`. It's rejected. Why? (`git lg --all` again: compare `receipt-totals` with `origin/receipt-totals`.) Git's hint says to pull: don't, or you'd merge the old commits back in and undo the rebase.
4. Push the safe way:

   ```
   git push --force-with-lease
   ```

   The lease means "only overwrite the branch if it's still where I last saw it".

## Step 2 - Alex pushed to your branch (about 10 minutes)

1. Alex pushes a commit to your branch (still in `me/`):

   ```
   bash ../teammate.sh
   ```

2. You, unaware, add a note and amend your last commit:

   ```
   echo "Totals include tax." >> README.md
   git commit -a --amend -m "Add receipt notes and explain the total"
   ```

3. Push with the lease: `git push --force-with-lease`. Rejected as **stale info**: the branch isn't where you last saw it. The lease just saved Alex's commit.
4. Now the trap. VS Code fetches in the background every few minutes ("autofetch"). Simulate it: `git fetch`. Your `origin/receipt-totals` now includes Alex's commit, so a plain `--force-with-lease` would succeed **and delete it**. Don't. Instead:

   ```
   git push --force-with-lease --force-if-includes
   ```

   Rejected again: `--force-if-includes` also checks that what you fetched is actually part of your branch.
5. Bring Alex's commit in, then push. No force needed this time:

   ```
   git pull --rebase
   git lg
   git push
   ```

Tip: `git config --global push.useForceIfIncludes true` makes every `--force-with-lease` also check this.

## Step 3 - main is protected (about 3 minutes)

Try to rewrite and delete `main` on "Bitbucket":

```
git push --force origin origin/main~1:main
git push origin --delete main
```

Both are refused with "Permission denied", the same message Bitbucket gives for a branch permission. Git shows it as `pre-receive hook declined`. You can't change this: an admin sets branch permissions, once, for the whole repository.

## Stretch

- Rebuild (`bash lab force-push`), redo step 1 up to the rebase, and before pushing run `git range-diff @{u}...@`. It compares the old and new versions of your branch commit by commit: what a reviewer needs after a force push.
- Look at the server side: `cat ../bitbucket.git/hooks/pre-receive`. Real Bitbucket does the same check in its own code.

## Debrief

- Which push would have silently deleted Alex's commit, and why?
- What does Bitbucket do to an open pull request when you force push to it?
- When is a plain `--force` ever OK?
