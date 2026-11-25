# Checks for the conflicts lab. Checks results, not exact hashes.

subject_on_main() { git log --format=%H -1 --grep="^$1\$" main; }

nothing_in_progress() {
  [ ! -d .git/rebase-merge ] && [ ! -d .git/rebase-apply ] && [ ! -f .git/MERGE_HEAD ]
}

no_conflict_markers() {
  ! git grep -qE '^(<<<<<<<|>>>>>>>|\|\|\|\|\|\|\||=======$)' main -- . 2>/dev/null
}

loyalty_rebased() { # loyalty sits on top of the teammate's work, with no merge commits of its own
  local teammate
  teammate="$(subject_on_main 'Mention rounding in the README')"
  [ -n "$teammate" ] && git merge-base --is-ancestor "$teammate" loyalty &&
    [ -z "$(git rev-list --merges "$teammate..loyalty")" ] &&
    [ "$(git rev-list --count "$teammate..loyalty")" -eq 2 ]
}

loyalty_merged_no_ff() { # a merge commit on main whose second parent is loyalty
  local m
  for m in $(git rev-list --merges main); do
    [ "$(git rev-parse "$m^2")" = "$(git rev-parse loyalty)" ] && return 0
  done
  return 1
}

footer_fast_forwarded() { # main is exactly receipt-footer, on top of the loyalty merge
  local m=""
  for m in $(git rev-list --merges main); do break; done
  [ -n "$m" ] && [ "$(git rev-parse main)" = "$(git rev-parse receipt-footer)" ] &&
    [ "$(git rev-list --count --merges "$m..main")" -eq 0 ] &&
    [ "$(git rev-list --count "$m..main")" -eq 1 ]
}

main_passes_tests() {
  local tmp result=1
  tmp="$(mktemp -d)"
  git archive main | tar -x -C "$tmp"
  for t in rounding loyalty footer; do [ -f "$tmp/tests/$t.sh" ] || { rm -rf "${tmp:?}"; return 1; }; done
  bash "$tmp/test.sh" >/dev/null 2>&1 && result=0
  rm -rf "${tmp:?}"
  return "$result"
}

readme_has_both_notes() {
  git show main:README.md | grep -q 'rounded to the nearest cent' &&
    git show main:README.md | grep -q 'Loyalty members get 5% off'
}

run_checks() {
  goal "No rebase or merge is still in progress" nothing_in_progress
  goal "loyalty is rebased onto main's latest work (no merge commits in it)" loyalty_rebased
  goal "loyalty is merged into main with a merge commit (--no-ff)" loyalty_merged_no_ff
  goal "receipt-footer is rebased and fast-forwarded into main" footer_fast_forwarded
  goal "No conflict markers left on main" no_conflict_markers
  goal "Both README notes kept (rounding and loyalty)" readme_has_both_notes
  goal "Every change kept: all tests pass on main" main_passes_tests
}
