# Changelog

## 0.2.0 (unreleased)

- Labs: force-push (Rebase workflows with Bitbucket), bisect (Finding when and why things changed), air-gap capstone (History cleanup, strategies and structure; needs git-lfs).
- Try-its: 26 more, one or more for every section, plus rerere. `try/README.md` is generated from `try/parts/` (`bash tests/build-try-readme.sh`).
- The tool says clearly when a lab needs git-lfs and it isn't installed.
- peek-inside starts with a look around `.git` (HEAD, a branch file, the objects folder); now 4 minutes.
- Started from WSL against a Windows folder (typing `bash` in PowerShell), the tool stops and says to use `.\lab.cmd` or Git Bash; `lab doctor` reports it.
- Lab READMEs say to work in Git Bash on Windows.
- Fixes from a full play-test: `git lfs ls-files` and `bundle verify` hints, the bare-repo-on-the-stick stretch (needs a named remote for LFS), autofetch wording (off by default in VS Code), clearer hints in reviewable, escape-room, force-push and conflicts, and `--check` no longer counts goals that are already true before you start.

## 0.1.0

- The `lab` tool: list, doctor, play, try, hint, open, version; build a lab at any step (`--step`), rebuild one room (`--room`), check a lab (`--check`).
- `lab.cmd` launcher for Windows (cmd and PowerShell).
- Labs: conflicts (Merging vs. rebasing), reviewable (Crafting clean history), escape-room (Undo almost anything).
- Try-its: playground, peek-inside.
- Tests on Linux, macOS and Windows, with the same commit hashes everywhere (`tests/expected-refs.txt`).
