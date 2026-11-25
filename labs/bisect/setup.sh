# Lab: Bisect (Finding when and why things changed).
# main has 300 commits. v1.0 (commit 100) passed the tests; somewhere after it, total 999 broke.
# Built with git fast-import, so it is quick and has the same hashes everywhere.

LAB_STEPS=2 # step 2 starts with the culprit already tagged first-bad
BISECT_COMMITS=300
BISECT_BAD=217   # the commit that breaks rounding
BISECT_GOOD_TAG=100

bisect_price() { # bisect_price <good|bad>
  if [ "$1" = good ]; then
    printf '%s\n' '# Price calculation. Amounts are in cents.' 'TAX_PERCENT=8' '' \
      'total() {' '  # total <subtotal>' '  local subtotal=$1 tax' \
      '  tax=$(( (subtotal * TAX_PERCENT + 50) / 100 ))' '  echo $(( subtotal + tax ))' '}'
  else
    printf '%s\n' '# Price calculation. Amounts are in cents.' 'TAX_PERCENT=8' '' \
      'total() {' '  # total <subtotal>' '  local subtotal=$1 tax' \
      '  tax=$(( subtotal * TAX_PERCENT / 100 ))' '  echo $(( subtotal + tax ))' '}'
  fi
}

bisect_test() {
  printf '%s\n' '#!/usr/bin/env bash' \
    '# Exits 0 when the tests pass, 1 when they fail (what git bisect run expects).' \
    'cd "$(dirname "$0")" || exit 2' \
    '. src/price.sh' \
    '[ "$(total 1000)" = 1080 ] || { echo "FAIL: total 1000 is $(total 1000), expected 1080"; exit 1; }' \
    '[ "$(total 999)" = 1079 ] || { echo "FAIL: total 999 is $(total 999), expected 1079 (tax rounds to the nearest cent)"; exit 1; }' \
    'echo "All tests passed."'
}

bisect_message() { # bisect_message <n>: a plausible commit subject
  case "$1" in
    1) echo "Add the price calculator and tests" ;;
    "$BISECT_BAD") echo "Simplify the tax calculation" ;;
    *)
      case $(( $1 % 5 )) in
        0) echo "Add catalog item $1" ;;
        1) echo "Update the price of item $(( $1 - 1 ))" ;;
        2) echo "Fix a typo in item $(( $1 - 2 ))" ;;
        3) echo "Add catalog item $1 and its notes" ;;
        *) echo "Reorder catalog notes ($1)" ;;
      esac ;;
  esac
}

emit_blob() { # emit_blob <path> <content>
  printf 'M 100644 inline %s\ndata %d\n%s\n' "$1" "${#2}" "$2"
}

build_step() {
  new_repo .
  local n=1 ts catalog="" msg price
  {
    while [ "$n" -le "$BISECT_COMMITS" ]; do
      ts=$(( 1767225600 + n * 3600 ))
      msg="$(bisect_message "$n")"
      catalog="${catalog}Item $n: $(( 100 + (n * 37) % 900 )) cents
"
      echo "commit refs/heads/main"
      echo "mark :$n"
      echo "author Sam Developer <sam@example.com> $ts +0000"
      echo "committer Sam Developer <sam@example.com> $ts +0000"
      printf 'data %d\n%s\n' "${#msg}" "$msg"
      if [ "$n" -gt 1 ]; then echo "from :$(( n - 1 ))"; fi
      if [ "$n" -eq 1 ]; then
        emit_blob test.sh "$(bisect_test)"
        emit_blob README.md "# Shop

Run the tests: bash test.sh"
      fi
      if [ "$n" -eq 1 ] || [ "$n" -eq "$BISECT_BAD" ]; then
        if [ "$n" -lt "$BISECT_BAD" ]; then price="$(bisect_price good)"; else price="$(bisect_price bad)"; fi
        emit_blob src/price.sh "$price"
      fi
      # The bad commit only touches the price code, so reverting it later is clean.
      if [ "$n" -ne "$BISECT_BAD" ]; then emit_blob catalog.txt "$catalog"; fi
      echo
      n=$(( n + 1 ))
    done
    echo "reset refs/tags/v1.0"
    echo "from :$BISECT_GOOD_TAG"
    echo
  } > .git/lab-import
  git fast-import --quiet < .git/lab-import
  rm -f .git/lab-import
  git reset -q --hard main
  echo "culprit=$(git rev-parse "main~$(( BISECT_COMMITS - BISECT_BAD ))")" > .git/lab-bisect
  if [ "$1" -ge 2 ]; then git tag first-bad "main~$(( BISECT_COMMITS - BISECT_BAD ))"; fi
}
