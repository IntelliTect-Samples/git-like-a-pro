# Lab: Make it reviewable

About 40 minutes. Section: Crafting clean history.

On Windows, work in **Git Bash** (in VS Code: Terminal > New Terminal > Git Bash). The commands below assume it; in PowerShell, `bash` can start WSL's Linux instead, and some commands fail there.

The `discounts` branch works, but its history is a mess: WIP commits, typo fixes, a debug line added and removed, a commit that mixes two changes, and commits where the tests fail. Before anyone reviews it (or carries it across as patches, one file per commit), turn it into four clean commits that each pass the tests.

## Set up

```
bash lab reviewable
```

Then `cd` into the folder it prints. Jumping in late, or want a clean start at a later step? Build that step directly, for example:

```
bash lab reviewable --step 3
```

Check your progress at any time (run it from the kit folder):

```
bash lab reviewable --check
```

Stuck on a step? `bash lab hint reviewable <step>`.

## Look first

```
git lg --all
git log --stat main..discounts
bash test.sh
```

The project is a tiny shell price calculator; `bash test.sh` runs its tests.

## Step 1 - Squash the noise (about 12 minutes)

Use an interactive rebase onto `main`:

```
git rebase -i main
```

Aim for three commits now (step 2 splits the last one, making four):

1. **Add discount codes SAVE10 and SAVE25** from `wip discounts`, `more codes + tests` and `fix typo`
2. **Apply a discount code before tax** from `apply discount` and `fix test` (move `fix test` up)
3. **Show discounts on the receipt and document them** from `receipt and docs`, `wip` and `typo`

The `debug` commit and the `remove debug` commit should both disappear. Give every commit a clear message (`reword`).

## Step 2 - Split the mixed commit (about 8 minutes)

Commit 3 changes the receipt and the README at the same time. Split it into:

- **Show the discount on the receipt** (`src/receipt.sh`, `tests/receipt.sh`)
- **Document discount codes** (`README.md`)

Mark it `edit` in `git rebase -i main`, then undo the commit while keeping its changes and commit the pieces separately. Watch out: `tests/receipt.sh` is a new file, so `git commit -a` won't pick it up.

## Step 3 - Squash in a review fix (about 8 minutes)

A reviewer asks: "Codes should ignore case, so `save10` works too." The fix belongs in the first commit, not in a new one at the end.

1. Change `discount_percent` in `src/discounts.sh` so the code's case doesn't matter. One portable way is to change its `case "$1" in` line to:

   ```
   case "$(printf '%s' "$1" | tr '[:lower:]' '[:upper:]')" in
   ```
2. Add a test to `tests/discounts.sh`:

   ```
   expect "codes ignore case" "$(discount_percent save10)" "10"
   ```

3. Commit it as a fixup of the first commit, then let Git move it into place:

   ```
   git commit -a --fixup=<hash of "Add discount codes SAVE10 and SAVE25">
   git rebase -i --autosquash main
   ```

## Step 4 - Prove every commit passes (about 5 minutes)

```
git rebase --exec "bash test.sh" main
```

Git replays each commit and runs the tests after it, stopping at the first failure. Then run `bash lab reviewable --check` from the kit folder. (If you jumped in with `--step 4`, the branch is already clean: this step is the proof, not a fix.)

## Stretch

- Turn the branch into a patch series, one file per commit: `git format-patch main -o ../patches`. Open one: it's plain text a reviewer can read.
- Rebuild step 1 and do it again with `git commit --fixup` and `--autosquash` instead of editing the todo list by hand.
- If a file had mixed both changes, how would you split it? Try `git add -p` and its `s` (split) and `e` (edit) options.

## Debrief

- Which history would you rather review: before or after?
- What made the commits that failed the tests easy to miss?
- When would you use `--fixup` during a pull request instead of a new commit?
