### bundle

```
bash lab try bundle
```

A bundle is a whole repo, or just some new commits, in one file you can carry on a USB stick or attach to a ticket.

1. Put all of `main` in a bundle and check it:

   ```
   cd shop
   git bundle create ../shop.bundle main
   git bundle verify ../shop.bundle
   ```

   `verify` lists the ref inside and says the bundle "records a complete history" and is okay.

2. Clone a new repo from the file, as if on the other side of an air gap:

   ```
   cd ..
   git clone -b main shop.bundle offline
   git -C offline log --oneline -1
   git -C shop log --oneline -1
   ```

   You get the same hash on both sides, because a bundle carries the commit objects themselves and nothing is rewritten. Without `-b main` the clone would have no branch to check out, since this bundle doesn't include `HEAD`.

3. Make a new commit in `shop`, then bundle only that commit:

   ```
   cd shop
   echo "Free shipping over 50." >> README.md
   git commit -am "Add free shipping"
   git bundle create ../update.bundle main~1..main
   ```

4. Check it from the other repo, then fetch from it:

   ```
   cd ../offline
   git bundle verify ../update.bundle
   git fetch ../update.bundle main
   git merge --ff-only FETCH_HEAD
   git log --oneline -2
   ```

   This time `verify` shows the commit the bundle "requires", which the receiving repo must already have. The new commit arrives with the same hash it has in `shop`.

Extra: run `git init ../empty`, then `git -C ../empty bundle verify ../update.bundle`. It fails, because an incremental bundle is no use to a repo that lacks its prerequisite commit.
