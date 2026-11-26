# Lab: Force push safely

Plan on about 25 minutes. This one belongs to the section on rebase workflows with Bitbucket, and it works well in pairs, with one of you typing and the other predicting what Git will say.

On Windows, work in **Git Bash** (in VS Code: Terminal > New Terminal > Git Bash). The commands below assume it. In PowerShell, `bash` can start WSL's Linux instead, and some commands fail there.

Teams that rebase their pull request branches have to force push. A rebase makes new commits, so the branch on the server is no longer part of yours. This lab is about doing that without ever losing someone else's work.

Everything runs locally:

- `bitbucket.git` stands in for Bitbucket. Like a branch permission, it refuses force pushes and deletes on `main`.
- `me/` is your clone. Your pull request branch is `receipt-totals`.
- `teammate.sh` plays your teammate Alex, who pushes to the same "server" from `alex/`.

## Set up

```
bash lab force-push
cd "<the folder it prints>"
cd me
```

To start at a later step, run `bash lab force-push --step 2` (or 3). From the kit folder, `bash lab force-push --check` checks your progress and `bash lab hint force-push <step>` shows a hint.

## Step 1 - main moved under your pull request (about 8 minutes)

Alex merged something into `main` while your pull request was open. You don't know yet.

1. Run `git lg --all`. Your `origin/main` is old because you haven't fetched.
2. Fetch and rebase onto the new `main`:

   ```
   git fetch
   git lg --all
   git rebase origin/main
   ```

3. Push the usual way with `git push`. It's rejected, but why? Run `git lg --all` again and compare `receipt-totals` with `origin/receipt-totals`. Git's hint tells you to pull. Don't, or you'd merge the old commits back in and undo the rebase.
4. Push the safe way:

   ```
   git push --force-with-lease
   ```

   The lease means "only overwrite the branch if it's still where I last saw it".

## Step 2 - Alex pushed to your branch (about 10 minutes)

1. Alex pushes a commit to your branch (you stay in `me/`):

   ```
   bash ../teammate.sh
   ```

2. You don't know that, so you add a note and amend your last commit:

   ```
   echo "Totals include tax." >> README.md
   git commit -a --amend -m "Add receipt notes and explain the total"
   ```

3. Push with the lease, `git push --force-with-lease`. It's rejected as **stale info** because the branch isn't where you last saw it. The lease just saved Alex's commit.
4. Now for the trap. Tools fetch behind your back. VS Code does it every 3 minutes once you turn on autofetch (it's off by default), and other tools do too. Simulate that with `git fetch`. Your `origin/receipt-totals` now includes Alex's commit, so a plain `--force-with-lease` would succeed **and delete it**. Don't do that. Instead:

   ```
   git push --force-with-lease --force-if-includes
   ```

   Rejected again, since `--force-if-includes` also checks that what you fetched is actually part of your branch.
5. Bring Alex's commit in and push. You don't need to force this time:

   ```
   git pull --rebase
   git lg
   git push
   ```

If you want every `--force-with-lease` to make this check too, set `git config --global push.useForceIfIncludes true`.

## Step 3 - main is protected (about 3 minutes)

Try to rewrite and delete `main` on "Bitbucket":

```
git push --force origin origin/main~1:main
git push origin --delete main
```

Both are refused with "Permission denied", the same message Bitbucket gives for a branch permission. Git reports it as `pre-receive hook declined`. You can't change this yourself, because an admin sets branch permissions once for the whole repository.

## Stretch

- Rebuild with `bash lab force-push`, redo step 1 up to the rebase, and run `git range-diff @{u}...@` before you push. It compares the old and new versions of your branch commit by commit, which is what a reviewer needs after a force push.
- Have a look at the server side with `cat ../bitbucket.git/hooks/pre-receive`. Real Bitbucket makes the same check in its own code.

## Debrief

- Which push would have silently deleted Alex's commit, and why?
- What does Bitbucket do to an open pull request when you force push to it?
- When is a plain `--force` ever OK?
