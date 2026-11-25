# Hints: Bisect

Show one with `bash lab hint bisect <step>`.

## Step 1 - Bisect by hand, then let Git do it

- `git bisect start <bad> <good>`: the bad one comes first.
- Marked one wrong? `git bisect log > ../answers.txt`, fix the wrong line in that file, then `git bisect reset` and `git bisect replay ../answers.txt` (outside the repo, so it doesn't show up in `git status`).
- `bisect run` needs the command's exit code to mean good or bad. `bash test.sh` exits 0 when the tests pass and 1 when they fail.
- The first bad commit is "Simplify the tax calculation". Its diff (`git show first-bad`) drops the `+ 50` that rounded to the nearest cent.
- Forgot to tag it before `git bisect reset`? `git reflog` or `git log --oneline -S "+ 50" -- src/price.sh` finds it again.

## Step 2 - Fix main

- Make sure you're on `main` (`git bisect reset` does that). A revert while still bisecting lands on a detached HEAD.
- `git revert first-bad` opens your editor for the message. Save and close (or add `--no-edit`).
