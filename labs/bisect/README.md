# Lab: Bisect

About 15 minutes. Section: Finding when and why things changed.

`main` has 300 commits. The `v1.0` tag (commit 100) passed the tests. Today `bash test.sh` fails: tax on 999 cents is no longer rounded to the nearest cent. Find the commit that broke it, without reading 200 commits.

## Set up

```
bash lab bisect
```

Then `cd` into the folder it prints. Check progress from the kit folder with `bash lab bisect --check`; hints with `bash lab hint bisect <step>`. Start at step 2 (the culprit already tagged) with `bash lab bisect --step 2`.

```
bash test.sh
git log --oneline | wc -l
git log --oneline v1.0 -1
```

## Step 1 - Bisect by hand, then let Git do it (about 10 minutes)

1. Start, telling Git one bad and one good commit:

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

   Each answer halves what's left. Git shows "roughly N steps" to go.

3. Let Git finish on its own. `bisect run` runs the command at every step and reads its exit code (0 = good, 125 = can't test so skip it, any other 1-127 = bad):

   ```
   git bisect run bash test.sh
   ```

4. Git prints "... is the first bad commit". Mark it, then end the bisect (this puts you back on `main`):

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

- `git bisect log` (during a bisect) shows your answers so far; `git bisect replay` can redo them.
- What if some commits can't be tested (they don't build)? Your test script exits 125 for those and `bisect run` skips them. Or mark one by hand: `git bisect skip`.
- Bisecting something that isn't a bug? `git bisect start --term-old=slow --term-new=fast` lets you use your own words.
- Faster still: `git log -S "+ 50" --oneline -- src/price.sh` finds when that text disappeared. Bisect is for when you don't know which line to look for.

## Debrief

- How many steps did it take for 200 commits? How many would 2,000 take?
- What makes a good `bisect run` script? What would yours run in your real projects?
- Why did the commit message not give it away?
