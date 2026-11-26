### rerere

```
bash lab try rerere
```

You're on `feature`, which changes the same line as `main`. rerere ("reuse recorded resolution") remembers how you fixed a conflict and replays that fix the next time the same conflict shows up, say when you rebase a long-lived branch again.

1. Turn it on for this repo:

   ```
   git config rerere.enabled true
   ```

2. Rebase and run into the conflict. Watch for `Recorded preimage for 'greeting.txt'` near the end of the output.

   ```
   git rebase main
   ```

3. Resolve it in VS Code or any editor. Make the first line `Welcome to our shop, friend.`, delete the markers, and then run:

   ```
   git add greeting.txt
   git rebase --continue
   ```

   This time Git says `Recorded resolution for 'greeting.txt'.`

4. Now pretend you have to do it all again. Undo the rebase and repeat it:

   ```
   git reset --hard ORIG_HEAD
   git rebase main
   ```

   It's the same conflict, but Git says `Resolved 'greeting.txt' using previous resolution.` and the file already has your fix. Check it, then `git add greeting.txt` and `git rebase --continue`.

If you want Git to stage replayed resolutions for you, set `git config rerere.autoUpdate true`. And if you recorded a bad fix, `git rerere forget greeting.txt` drops it.
