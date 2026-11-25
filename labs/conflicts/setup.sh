# Lab: Conflicts (Merging vs. rebasing).
# main has two teammate commits; loyalty and receipt-footer branched off before them.
# Steps: 1 nothing done, 2 loyalty rebased and resolved, 3 loyalty merged with --no-ff.

LAB_STEPS=3

# ---------------------------------------------------------------- file versions

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
expect "receipt shows the total" "$(receipt 1000 | grep '^Total')" "Total: 1080"
for t in tests/*.sh; do
  if [ -f "$t" ]; then . "$t"; fi
done
if [ "$fail" -eq 0 ]; then echo "All tests passed."; fi
exit "$fail"
EOF
}

readme() { # readme [rounding] [loyalty]: the README with any of the two notes
  put README.md <<'EOF'
# Shop

A tiny price calculator for the Git like a pro labs. Amounts are in cents.

## Pricing

Tax is 8%, added to the subtotal.
EOF
  local note
  for note in "$@"; do
    case "$note" in
      rounding) echo "Tax is rounded to the nearest cent." >> README.md ;;
      loyalty)  echo "Loyalty members get 5% off before tax." >> README.md ;;
    esac
  done
  cat >> README.md <<'EOF'

Run the tests: bash test.sh
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

price_rounding() { # the teammate's change
  put src/price.sh <<'EOF'
# Price calculation. Amounts are in cents.
TAX_PERCENT=8

total() {
  # total <subtotal>
  local subtotal=$1 tax
  tax=$(( (subtotal * TAX_PERCENT + 50) / 100 ))
  echo $(( subtotal + tax ))
}
EOF
  put tests/rounding.sh <<'EOF'
expect "tax is rounded to the nearest cent" "$(total 999)" "1079"
EOF
}

price_loyalty() { # the loyalty branch's change, written against the old code
  put src/price.sh <<'EOF'
# Price calculation. Amounts are in cents.
TAX_PERCENT=8

total() {
  # total <subtotal> [member]
  local subtotal=$1
  if [ "${2:-}" = member ]; then subtotal=$(( subtotal - subtotal * 5 / 100 )); fi
  echo $(( subtotal + subtotal * TAX_PERCENT / 100 ))
}
EOF
  put tests/loyalty.sh <<'EOF'
expect "members get 5% off before tax" "$(total 1000 member)" "1026"
expect "members see the discount on the receipt" "$(receipt 1000 member | grep '^Total')" "Total: 1026"
EOF
}

price_resolved() { # both changes kept
  put src/price.sh <<'EOF'
# Price calculation. Amounts are in cents.
TAX_PERCENT=8

total() {
  # total <subtotal> [member]
  local subtotal=$1 tax
  if [ "${2:-}" = member ]; then subtotal=$(( subtotal - subtotal * 5 / 100 )); fi
  tax=$(( (subtotal * TAX_PERCENT + 50) / 100 ))
  echo $(( subtotal + tax ))
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

receipt_loyalty() {
  put src/receipt.sh <<'EOF'
# Receipt printing. Amounts are in cents.

receipt() {
  # receipt <subtotal> [member]
  echo "Subtotal: $1"
  echo "Total: $(total "$1" "${2:-}")"
}
EOF
}

receipt_footer() { # the receipt-footer branch's change, written against the old code
  put src/receipt.sh <<'EOF'
# Receipt printing. Amounts are in cents.

receipt() {
  # receipt <subtotal>
  echo "Subtotal: $1"
  echo "Total: $(total "$1")"
  echo "Thank you for shopping!"
}
EOF
  put tests/footer.sh <<'EOF'
expect "receipts end with a thank-you" "$(receipt 1000 | tail -n 1)" "Thank you for shopping!"
EOF
}

receipt_resolved() {
  put src/receipt.sh <<'EOF'
# Receipt printing. Amounts are in cents.

receipt() {
  # receipt <subtotal> [member]
  echo "Subtotal: $1"
  echo "Total: $(total "$1" "${2:-}")"
  echo "Thank you for shopping!"
}
EOF
}

# ---------------------------------------------------------------- states

build_base() {
  new_repo .
  readme
  price_base
  receipt_base
  test_runner
  commit "Add the price calculator, receipts and tests"
  BASE="$(git rev-parse HEAD)"

  git switch -q -c receipt-footer
  receipt_footer;           commit "Thank customers at the end of the receipt"

  git switch -q -c loyalty "$BASE"
  price_loyalty
  receipt_loyalty;          commit "Take 5% off for loyalty members"
  readme loyalty;           commit "Document the loyalty discount"

  git switch -q main
  as_teammate
  price_rounding;           commit "Round tax to the nearest cent"
  readme rounding;          commit "Mention rounding in the README"
  as_author
}

build_loyalty_rebased() { # loyalty as it looks after a correct rebase onto main
  git switch -q -C loyalty main
  price_loyalty; price_resolved
  receipt_loyalty;          commit "Take 5% off for loyalty members"
  readme rounding loyalty;  commit "Document the loyalty discount"
}

build_step() {
  build_base
  if [ "$1" -ge 2 ]; then build_loyalty_rebased; fi
  if [ "$1" -ge 3 ]; then
    git switch -q main
    tick
    git merge -q --no-ff -m "Merge branch 'loyalty'" loyalty
  fi
  git switch -q main
  git config merge.conflictStyle zdiff3
}
