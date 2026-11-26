# Changelog

## 0.2.0 (unreleased)

- New labs: force-push (Rebase workflows with Bitbucket), bisect (Finding when and why things changed) and the air-gap capstone (History cleanup, strategies and structure), which needs git-lfs.
- 26 more Try-its, at least one for every section, plus rerere. `try/README.md` is now generated from `try/parts/` by `bash tests/build-try-readme.sh`.
- The tool tells you plainly when a lab needs git-lfs and it isn't installed.
- peek-inside now opens with a look around `.git` (HEAD, a branch file, the objects folder) and takes 4 minutes.
- Started from WSL against a Windows folder (typing `bash` in PowerShell), the tool stops and tells you to use `.\lab.cmd` or Git Bash. `lab doctor` reports this too.
- Lab READMEs tell Windows users to work in Git Bash.
- Fixed the `git lfs ls-files` and `bundle verify` hints. The bare-repo-on-the-stick stretch now uses a named remote, which LFS needs. Autofetch wording corrected (it's off by default in VS Code). Clearer hints in reviewable, escape-room, force-push and conflicts.
- `--check` no longer counts goals that were already true before you started.

## 0.1.0

- The `lab` tool with list, doctor, play, try, hint, open and version. It can build a lab at any step (`--step`), rebuild one room (`--room`) and check a lab (`--check`).
- `lab.cmd` launcher for Windows (cmd and PowerShell).
- Labs: conflicts (Merging vs. rebasing), reviewable (Crafting clean history), escape-room (Undo almost anything).
- Try-its: playground, peek-inside.
- Tests on Linux, macOS and Windows, with the same commit hashes everywhere (`tests/expected-refs.txt`).
