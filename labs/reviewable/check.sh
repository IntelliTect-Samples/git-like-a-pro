# Checks for the reviewable lab. Checks results, not exact hashes: any clean route counts.

feature_commits() { git rev-list --reverse main..discounts; }

has_four_commits() { [ "$(git rev-list --count main..discounts)" -eq 4 ]; }

built_on_main() {
  git merge-base --is-ancestor main discounts && [ "$(git rev-list --count main)" -eq 3 ]
}

no_noise_messages() {
  ! git log --format=%s main..discounts | grep -qiE '^(wip|fixup!|squash!|amend!)|typo|debug|more codes|fix test|^receipt and docs$|^apply discount$'
}

no_debug_lines() { [ -z "$(git log -G DEBUG --format=%h main..discounts)" ]; }

receipt_and_docs_separate() {
  local c files
  for c in $(feature_commits); do
    files="$(git diff-tree --no-commit-id --name-only -r "$c")"
    if printf '%s\n' "$files" | grep -qx 'src/receipt.sh' && printf '%s\n' "$files" | grep -qx 'README.md'; then
      return 1
    fi
  done
}

extract() { # extract <commit> <dir>
  mkdir -p "$2"
  git archive "$1" | tar -x -C "$2"
}

case_fix_in_first_commit() {
  local first tmp result
  first="$(feature_commits | head -n 1)"
  [ -n "$first" ] || return 1
  tmp="$(mktemp -d)"
  extract "$first" "$tmp"
  result="$(cd "$tmp" && . src/discounts.sh 2>/dev/null && discount_percent save10)"
  rm -rf "${tmp:?}"
  [ "$result" = 10 ]
}

every_commit_passes() {
  local c tmp ok=0
  for c in $(feature_commits); do
    tmp="$(mktemp -d)"
    extract "$c" "$tmp"
    bash "$tmp/test.sh" >/dev/null 2>&1 || ok=1
    rm -rf "${tmp:?}"
  done
  return "$ok"
}

no_rebase_in_progress() { [ ! -d .git/rebase-merge ] && [ ! -d .git/rebase-apply ]; }

run_checks() {
  goal "No rebase is still in progress" no_rebase_in_progress
  goal "discounts is still built on main (main unchanged)" built_on_main
  goal "discounts has exactly 4 commits" has_four_commits
  goal "No WIP, typo, debug or fixup commits are left" no_noise_messages
  goal "No commit adds a DEBUG line" no_debug_lines
  goal "Receipt changes and README changes are in separate commits" receipt_and_docs_separate
  goal "Codes ignore case (save10), fixed inside the first commit" case_fix_in_first_commit
  goal "Every commit passes bash test.sh" every_commit_passes
}
