# Hints: Bisect

Show one with `bash lab hint bisect <step>`.

## Step 1 - Bisect by hand, then let Git do it

- In `git bisect start <bad> <good>` the bad one comes first.
- Marked one wrong? Save your answers with `git bisect log > ../answers.txt` and fix the wrong line in that file. Then run `git bisect reset` and `git bisect replay ../answers.txt`. The file sits outside the repo so it doesn't show up in `git status`.
- `bisect run` needs the command's exit code to mean good or bad. `bash test.sh` exits 0 when the tests pass and 1 when they fail.
- The first bad commit is "Simplify the tax calculation". Its diff (`git show first-bad`) drops the `+ 50` that rounded to the nearest cent.
- Forgot to tag it before `git bisect reset`? You can find it again with `git reflog` or `git log --oneline -S "+ 50" -- src/price.sh`.

## Step 2 - Fix main

- Make sure you're on `main`, which `git bisect reset` takes care of. A revert while you're still bisecting lands on a detached HEAD.
- `git revert first-bad` opens your editor for the message. Save and close it, or add `--no-edit`.
