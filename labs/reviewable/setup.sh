# Lab: Make it reviewable (Crafting clean history).
# Builds a repo with main and a messy "discounts" branch.
# Steps: 1 messy branch, 2 noise squashed (3 commits), 3 mixed commit split (4 commits),
#        4 review fix squashed in (ready for the --exec check).

LAB_STEPS=4

# ---------------------------------------------------------------- file versions

readme_base() {
  put README.md <<'EOF'
# Shop

A tiny price calculator for the Git like a pro labs. Amounts are in cents.

Run the tests: bash test.sh
EOF
}

readme_docs_draft() { # first draft, with a typo
  readme_base
  cat >> README.md <<'EOF'

## Discount codes

- SAVE10: 10% off
- SAVE25: 25% off
EOF
}

readme_docs_typo() { # second draft, still with a typo
  readme_base
  cat >> README.md <<'EOF'

## Discount codes

Pass a code as the secnd argument to total or receipt:

- SAVE10: 10% off
- SAVE25: 25% off

Discounts apply before tax.
EOF
}

readme_docs() {
  readme_base
  cat >> README.md <<'EOF'

## Discount codes

Pass a code as the second argument to total or receipt:

- SAVE10: 10% off
- SAVE25: 25% off

Discounts apply before tax.
EOF
}

test_runner() {
  put test.sh <<'EOF'
#!/usr/bin/env bash
# Runs every test. Prints FAIL lines and exits non-zero if any test fails.
cd "$(dirname "$0")" || exit 2
for f in src/*.sh; do . "$f"; done
fail=0
expect() { # expect <description> <actual> <expected>
  if [ "$2" != "$3" ]; then
    echo "FAIL: $1: got '$2', expected '$3'"
    fail=1
  fi
}
expect "tax is added" "$(total 1000)" "1080"
expect "receipt shows the total" "$(receipt 1000 | tail -n 1)" "Total: 1080"
for t in tests/*.sh; do
  if [ -f "$t" ]; then . "$t"; fi
done
if [ "$fail" -eq 0 ]; then echo "All tests passed."; fi
exit "$fail"
EOF
}

price_base() {
  put src/price.sh <<'EOF'
# Price calculation. Amounts are in cents.
TAX_PERCENT=8

total() {
  # total <subtotal>
  local subtotal=$1
  echo $(( subtotal + subtotal * TAX_PERCENT / 100 ))
}
EOF
}

price_discount() {
  put src/price.sh <<'EOF'
# Price calculation. Amounts are in cents.
TAX_PERCENT=8

total() {
  # total <subtotal> [discount-code]
  local subtotal=$1 off
  off=$(discount_percent "${2:-}")
  subtotal=$(( subtotal - subtotal * off / 100 ))
  echo $(( subtotal + subtotal * TAX_PERCENT / 100 ))
}
EOF
}

price_debug() {
  put src/price.sh <<'EOF'
# Price calculation. Amounts are in cents.
TAX_PERCENT=8

total() {
  # total <subtotal> [discount-code]
  local subtotal=$1 off
  off=$(discount_percent "${2:-}")
  echo "DEBUG off=$off" >&2
  subtotal=$(( subtotal - subtotal * off / 100 ))
  echo $(( subtotal + subtotal * TAX_PERCENT / 100 ))
}
EOF
}

receipt_base() {
  put src/receipt.sh <<'EOF'
# Receipt printing. Amounts are in cents.

receipt() {
  # receipt <subtotal>
  echo "Subtotal: $1"
  echo "Total: $(total "$1")"
}
EOF
}

receipt_discount() {
  put src/receipt.sh <<'EOF'
# Receipt printing. Amounts are in cents.

receipt() {
  # receipt <subtotal> [discount-code]
  echo "Subtotal: $1"
  if [ -n "${2:-}" ]; then
    echo "Discount: $2 ($(discount_percent "$2")%)"
  fi
  echo "Total: $(total "$1" "${2:-}")"
}
EOF
  put tests/receipt.sh <<'EOF'
expect "receipt shows the discount" "$(receipt 1000 SAVE10 | sed -n 2p)" "Discount: SAVE10 (10%)"
EOF
}

discounts_one() { # first draft: one code, no tests
  put src/discounts.sh <<'EOF'
# Discount codes and the percentage each one takes off.

discount_percent() {
  # discount_percent <code>
  case "$1" in
    SAVE10) echo 10 ;;
    *) echo 0 ;;
  esac
}
EOF
}

discounts_two() {
  put src/discounts.sh <<'EOF'
# Discount codes and the percentage each one takes off.

discount_percent() {
  # discount_percent <code>
  case "$1" in
    SAVE10) echo 10 ;;
    SAVE25) echo 25 ;;
    *) echo 0 ;;
  esac
}
EOF
}

discounts_tests() { # $1 = "typo" for the misspelled version
  local word=discount
  [ "${1:-}" = typo ] && word=dicsount
  put tests/discounts.sh <<EOF
expect "SAVE10 is a 10% $word" "\$(discount_percent SAVE10)" "10"
expect "SAVE25 is a 25% $word" "\$(discount_percent SAVE25)" "25"
expect "unknown codes give no $word" "\$(discount_percent NOPE)" "0"
EOF
}

total_tests() { # $1 = expected total for SAVE10 (980 is the wrong first try)
  put tests/total.sh <<EOF
expect "SAVE10 comes off before tax" "\$(total 1000 SAVE10)" "$1"
EOF
}

discounts_any_case() { # the reviewer's fix: codes ignore case
  put src/discounts.sh <<'EOF'
# Discount codes and the percentage each one takes off.

discount_percent() {
  # discount_percent <code>  (any case: save10 works too)
  case "$(printf '%s' "$1" | tr '[:lower:]' '[:upper:]')" in
    SAVE10) echo 10 ;;
    SAVE25) echo 25 ;;
    *) echo 0 ;;
  esac
}
EOF
  discounts_tests
  echo 'expect "codes ignore case" "$(discount_percent save10)" "10"' >> tests/discounts.sh
}

# ---------------------------------------------------------------- states

build_main() {
  new_repo .
  readme_base
  price_base
  test_runner
  commit "Add the price calculator and tests"
  receipt_base
  commit "Print receipts"
  put .gitignore <<'EOF'
*.patch
EOF
  commit "Ignore patch files"
  git switch -q -c discounts
}

build_messy() {
  discounts_one;            commit "wip discounts"
  discounts_two
  discounts_tests typo;     commit "more codes + tests"
  discounts_tests;          commit "fix typo"
  price_discount
  total_tests 980;          commit "apply discount"
  price_debug;              commit "debug"
  receipt_discount
  readme_docs_draft;        commit "receipt and docs"
  readme_docs_typo;         commit "wip"
  total_tests 972;          commit "fix test"
  price_discount;           commit "remove debug"
  readme_docs;              commit "typo"
}

build_commit_a() { discounts_two; discounts_tests; commit "Add discount codes SAVE10 and SAVE25"; }
build_commit_b() { price_discount; total_tests 972; commit "Apply a discount code before tax"; }

build_step() {
  build_main
  case "$1" in
    1) build_messy ;;
    2) build_commit_a; build_commit_b
       receipt_discount; readme_docs; commit "Show discounts on the receipt and document them" ;;
    3) build_commit_a; build_commit_b
       receipt_discount; commit "Show the discount on the receipt"
       readme_docs;      commit "Document discount codes" ;;
    4) discounts_any_case; commit "Add discount codes SAVE10 and SAVE25"
       build_commit_b
       receipt_discount; commit "Show the discount on the receipt"
       readme_docs;      commit "Document discount codes" ;;
  esac
}
