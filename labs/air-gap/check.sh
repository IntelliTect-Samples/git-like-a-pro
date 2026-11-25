# Checks for the air-gap lab. Run from the workspace folder.

in_inside() { git -C inside "$@"; }

idle() { [ ! -d inside/.git/rebase-apply ] && [ ! -d inside/.git/rebase-merge ]; }

patched_branch() { # inside has a rates branch with all three commits, applied from patches
  local s
  for s in "Add exchange rates" "Add the rates chart" "Use units v1.1"; do
    in_inside log --format=%s rates 2>/dev/null | grep -qx "$s" || return 1
  done
}

lfs_content_inside() { # the chart's real content (not just the LFS pointer) is stored inside
  local oid
  oid="$(in_inside show rates:assets/chart.png 2>/dev/null | sed -n 's/^oid sha256://p')"
  [ -n "$oid" ] && [ -f "inside/.git/lfs/objects/$(printf '%s' "$oid" | cut -c1-2)/$(printf '%s' "$oid" | cut -c3-4)/$oid" ]
}

submodule_commit_inside() { # the library commit rates points at exists in the inside's copy of the library
  local want
  want="$(in_inside ls-tree rates vendor/units 2>/dev/null | awk '{ print $3 }')"
  [ -n "$want" ] && git -C inside-units.git cat-file -e "$want^{commit}" 2>/dev/null
}

submodule_checked_out() {
  local want
  want="$(in_inside ls-tree rates vendor/units 2>/dev/null | awk '{ print $3 }')"
  [ -n "$want" ] && [ "$(git -C inside/vendor/units rev-parse HEAD 2>/dev/null)" = "$want" ]
}

bundle_kept_hashes() { # some ref inside points at exactly outside's rates commit
  local want
  want="$(git -C outside rev-parse rates)"
  in_inside for-each-ref --format='%(objectname)' | grep -qx "$want"
}

run_checks() {
  goal "No git am is still in progress inside" idle
  goal "Step 1: inside has the rates branch, all three commits, from patches" patched_branch
  goal "Step 1: the chart's LFS content made it inside (not just the pointer)" lfs_content_inside
  goal "Step 2: the library commit the submodule needs is in inside-units.git" submodule_commit_inside
  goal "Step 2: inside/vendor/units is checked out at that commit" submodule_checked_out
  goal "Step 3: a branch inside has exactly outside's rates commit (from the bundle)" bundle_kept_hashes
}
