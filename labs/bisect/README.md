# Lab: Bisect

About 15 minutes, in the section on finding when and why things changed.

On Windows, work in **Git Bash** (in VS Code: Terminal > New Terminal > Git Bash). The commands below assume it. In PowerShell, `bash` can start WSL's Linux instead, and some commands fail there.

`main` has 300 commits. The `v1.0` tag (commit 100) passed the tests, but today `bash test.sh` fails because tax on 999 cents is no longer rounded to the nearest cent. Your job is to find the commit that broke it without reading 200 commits.

## Set up

```
bash lab bisect
```

Then `cd` into the folder it prints. From the kit folder, `bash lab bisect --check` checks your progress and `bash lab hint bisect <step>` shows a hint. To start at step 2 with the culprit already tagged, run `bash lab bisect --step 2`.

```
bash test.sh
git log --oneline | wc -l
git log --oneline v1.0 -1
```

## Step 1 - Bisect by hand, then let Git do it (about 10 minutes)

1. Start by telling Git one bad and one good commit:

   ```
   git bisect start main v1.0
   ```

   Git checks out a commit halfway between them.

2. Test it and tell Git the answer. Do this two or three times:

   ```
   bash test.sh
   git bisect good    # if the tests passed
   git bisect bad     # if they failed
   ```

   Each answer halves what's left, and Git tells you there are "roughly N steps" to go.

3. Now let Git finish on its own. `bisect run` runs the command at every step and reads its exit code. 0 means good, 125 means it can't be tested so Git skips it, and any other code from 1 to 127 means bad.

   ```
   git bisect run bash test.sh
   ```

4. When Git prints "... is the first bad commit", tag it and end the bisect, which puts you back on `main`:

   ```
   git tag first-bad <hash>
   git bisect reset
   git show first-bad
   ```

## Step 2 - Fix main (about 3 minutes)

`main` is shared, so undo the bad commit with a new commit instead of rewriting history:

```
git revert first-bad
bash test.sh
```

## Stretch

- During a bisect, `git bisect log` shows your answers so far and `git bisect replay` can redo them.
- What if some commits can't be tested because they don't build? Have your test script exit 125 for those and `bisect run` skips them. You can also mark one by hand with `git bisect skip`.
- Bisecting something that isn't a bug? `git bisect start --term-old=slow --term-new=fast` lets you use your own words.
- There's an even faster way here. On `main`, `git log -S "+ 50" --oneline -- src/price.sh` finds when that text disappeared. After step 2 it also lists your revert, which put the text back. Bisect is for when you don't know which line to look for.

## Debrief

- How many steps did it take for 200 commits? How many would 2,000 take?
- What makes a good `bisect run` script? What would yours run in your real projects?
- Why did the commit message not give it away?
