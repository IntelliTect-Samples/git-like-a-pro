### rerere

```
bash lab try rerere
```

You're on `feature`, which changes the same line as `main`. rerere ("reuse recorded resolution") remembers how you fixed a conflict and replays it the next time the same conflict appears, for example when you rebase a long-lived branch again.

1. Turn it on for this repo:

   ```
   git config rerere.enabled true
   ```

2. Rebase and hit the conflict. Near the end of the output Git says `Recorded preimage for 'greeting.txt'`:

   ```
   git rebase main
   ```

3. Resolve it in VS Code or any editor: make the first line `Welcome to our shop, friend.` and delete the markers. Then:

   ```
   git add greeting.txt
   git rebase --continue
   ```

   Git says `Recorded resolution for 'greeting.txt'.`

4. Pretend you have to do it again: undo the rebase and repeat it.

   ```
   git reset --hard ORIG_HEAD
   git rebase main
   ```

   Same conflict, but Git says `Resolved 'greeting.txt' using previous resolution.` and the file already has your fix. Check it, then `git add greeting.txt` and `git rebase --continue`.

Extra: `git config rerere.autoUpdate true` stages replayed resolutions for you, and `git rerere forget greeting.txt` drops a resolution you got wrong.
