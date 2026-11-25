# Lab: Escape room

About 40 minutes. Section: Undo almost anything.

Six repos, each broken in a different way. Get out of as many rooms as you can. The rooms don't depend on each other: do them in any order, skip one, or come back later.

## Set up

```
bash lab escape-room
```

This builds all six rooms as folders `room-1` to `room-6`. `cd` into the one you want. (`room-5.origin.git` is room 5's "server": the remote it pushes to.)

- Made things worse? Rebuild just that room: `bash lab escape-room --room 3` (the others stay as they are).
- See which rooms you've escaped (from the kit folder): `bash lab escape-room --check`
- Need a nudge? `bash lab hint escape-room <room>`

Short on time? Do rooms 1, 5 and 3 first: they're the ones that happen most on a team that rebases and shares branches.

Your best friends in here: `git reflog`, `git lg --all`, `ORIG_HEAD`, and `git status`, which often tells you what to do next.

## Room 1 - Reset too far

Someone ran `git reset --hard HEAD~3` on `main` to "clean up", then carried on working and committed "Open on Saturdays in December". Three gift card commits vanished.

**Escape when:** `main` has all three gift card commits back **and** still has the Saturday commit.

## Room 2 - The deleted branch

The `search` branch had two commits that were never merged. Someone deleted it with `git branch -D search`.

**Escape when:** the `search` branch exists again, pointing at its last commit.

## Room 3 - The bad rebase

You rebased `menu` onto `main`, hit a conflict in `prices.txt` and took your own version. The rebase finished, but the teammate's coffee price rise on `main` is gone from your branch.

**Escape when:** `menu` is back exactly as it was before the rebase. (Stretch: then redo the rebase and keep both changes.)

## Room 4 - The dropped stash

You stashed an idea in `notes.txt`, then ran `git stash drop` by mistake. `git stash list` is empty.

**Escape when:** the line about saving the cart is back in `notes.txt` (in your working folder or committed).

## Room 5 - The bad merge, already pushed

The `tax-change` branch was merged into `main` and pushed. It set tax to 80% and `bash test.sh` fails. Teammates have already pulled it, so rewriting `main` is not an option.

**Escape when:** a new commit on `main` undoes the **whole** merge (both of its commits: the tax change and the "Tax rules reviewed" note), the tests pass, and it's pushed to `origin`. The merge itself stays in the history. The check has two lines for this room.

## Room 6 - Wrong branch

You made two logo commits directly on `main`. They belong on a new branch, `receipt-logo`, and `main` should go back to where it was before them.

**Escape when:** `main` is back on "Add opening days" and `receipt-logo` has both logo commits.

## Debrief

- Which rooms needed the reflog, and which needed nothing but the commands you already knew?
- Room 5 vs. room 1: why revert in one and reset in the other?
- What would you do differently in room 3 next time, before running `git rebase --continue`?
