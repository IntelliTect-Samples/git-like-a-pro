# Git like a pro: labs

Hands-on exercises for the Git like a pro course. Every lab and Try-it builds its own practice repo from scratch, so you can start any of them at any time and in any order. Rebuild one whenever you want a clean start.

## If you only read this

```
git clone https://bitbucket.org/intellitect-samples/git-like-a-pro.git
cd git-like-a-pro
bash lab doctor
bash lab list
```

On Windows, Git Bash runs all of these as written. From PowerShell or Command Prompt, type `.\lab.cmd` instead of `bash lab`, as in `.\lab.cmd doctor`.

## Before the course

Run `bash lab doctor` and fix anything it marks as a PROBLEM. You need:

- **Git 2.40 or newer.** Apple's Git can be older, so on a Mac run `brew install git`.
- **git-lfs** for one part of the air-gap lab. Git for Windows already includes it. On a Mac, run `brew install git-lfs` and then `git lfs install`.
- **VS Code** as Git's editor (recommended). On a Mac, run "Shell Command: Install 'code' command in PATH" from VS Code's Command Palette so the `code` command works.

## How it works

| Command | What it does |
|---|---|
| `bash lab list` | Every lab and Try-it, in course order |
| `bash lab <lab>` | Build a lab from scratch, for example `bash lab reviewable` |
| `bash lab <lab> --step 3` | Build a lab as it looks at the start of step 3 (late, lost or want a clean start) |
| `bash lab <lab> --room 3` | Rebuild one room of the escape room, leaving the others as they are |
| `bash lab <lab> --check` | Show which of the lab's goals you've met |
| `bash lab hint <lab> <step>` | Show the hint for a step (or a room) |
| `bash lab try <name>` | Build a short Try-it repo, for example `bash lab try peek-inside` |
| `bash lab play` | Build or reset the playground repo |
| `bash lab open <lab>` | Open a lab's folder in VS Code |
| `bash lab doctor` | Check your tools and settings |
| `bash lab version` | Show the kit version |

Practice repos go in `~/git-labs`, never inside this folder. On Windows that's `C:\git-labs`, or `~/git-labs` if `C:\` isn't writable. Set `LAB_HOME` to use another folder. The tool only deletes folders it created itself, and it knows them by the hidden `.git-lab-workspace` file inside each one. Leave that file alone. Git ignores it.

Each lab's instructions are in its `README.md` under `labs/<lab>/`. The Try-its are all in [try/README.md](try/README.md).

Your own Git settings stay untouched. Each practice repo gets a few settings of its own (line endings, no commit signing, no shared hooks, a `git lg` alias) so the exercises behave the same on every machine.

## Something went wrong?

- Rebuild with `bash lab <lab>`, or add `--step <n>` to go back to where you were.
- Getting "You're inside ..."? Change to another folder first, for example `cd ~`.
- Paste the output of `bash lab doctor` when you ask for help.

## License

Scripts are under the [MIT License](LICENSE). Text (READMEs, hints, handouts) is under [CC BY 4.0](LICENSE-CONTENT.md).
