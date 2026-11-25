# Hints: Escape room

Show one with `bash lab hint escape-room <room>`.

## Room 1 - Reset too far

- `git reflog` lists every place HEAD has been, newest first. The line right below `reset: moving to HEAD~3` is where you were before the reset: "Show gift cards on the receipt".
- Resetting back to it would lose the Saturday commit. Instead, bring the lost commits back alongside it: `git merge <hash>`, `git cherry-pick <first>^..<last>`, or reset to the lost commit and then cherry-pick the Saturday commit.
- Right after the reset, `ORIG_HEAD` pointed at the lost commit. But every reset, merge or rebase overwrites it, so if you've tried one already, take the hash from `git reflog` instead.

## Room 2 - The deleted branch

- When you delete a branch, its commits stay in the repo for weeks. The branch's own reflog is gone, but HEAD's reflog remembers commits you made while you were on it.
- `git reflog` and look for `commit: Rank search results`.
- `git branch search <hash>` (or `git switch -c search <hash>`).

## Room 3 - The bad rebase

- After a rebase, `ORIG_HEAD` points at the branch tip from before the rebase.
- `git reset --hard ORIG_HEAD` while on `menu`. If you've done something else since, use the branch's reflog: `git reflog menu` and look for the entry just below `rebase (finish)` (the list is newest first).
- Stretch: `git rebase main` again, and this time edit `prices.txt` to keep the coffee price rise **and** the oat milk.

## Room 4 - The dropped stash

- A stash is a commit. Dropping it removes the name, not the commit.
- `git fsck --no-reflogs` lists "dangling commit" lines; one of them is your stash. `git show <hash>` to check: it's titled `WIP on main` and its diff has the `Idea:` line (shown in the two-column style Git uses for merges, because a stash commit has two parents).
- `git stash apply <hash>` puts the change back. (In your own work, `git stash drop` prints the hash it dropped, so scrolling up in your terminal works too.)

## Room 5 - The bad merge, already pushed

- The merge brought in two commits. Revert the merge, not one of them, and both are undone at once.
- `git revert` makes a new commit that undoes another one, without rewriting history.
- Reverting a merge needs `-m 1`: "keep the first parent's side (main) and undo what the other side brought in".
- `git revert -m 1 <merge-hash>`, then `bash test.sh`, then `git push`.
- Later, merging those commits again (`git merge <merge>^2`) won't bring the changes back: Git thinks they're already merged. You'd revert the revert.

## Room 6 - Wrong branch

- A branch is just a pointer. Create one where you are now, then move `main` back.
- `git branch receipt-logo` (it now has both commits), then `git reset --hard HEAD~2` on `main`.
- If you'd already pushed `main`, you'd revert the two commits instead.
