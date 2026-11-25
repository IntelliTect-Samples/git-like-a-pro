# Changelog

## 0.2.0 (unreleased)

- Labs: force-push (Rebase workflows with Bitbucket), bisect (Finding when and why things changed), air-gap capstone (History cleanup, strategies and structure; needs git-lfs).
- Try-its: 26 more, one or more for every section, plus rerere. `try/README.md` is generated from `try/parts/` (`bash tests/build-try-readme.sh`).
- The tool says clearly when a lab needs git-lfs and it isn't installed.

## 0.1.0

- The `lab` tool: list, doctor, play, try, hint, open, version; build a lab at any step (`--step`), rebuild one room (`--room`), check a lab (`--check`).
- `lab.cmd` launcher for Windows (cmd and PowerShell).
- Labs: conflicts (Merging vs. rebasing), reviewable (Crafting clean history), escape-room (Undo almost anything).
- Try-its: playground, peek-inside.
- Tests on Linux, macOS and Windows, with the same commit hashes everywhere (`tests/expected-refs.txt`).
