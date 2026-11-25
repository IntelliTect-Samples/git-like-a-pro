# Try-it: cherry-pick -x a hotfix onto a release branch. Built by: bash lab try cherry-pick-hotfix
# release/1.0 branched off before main got two features and, between them, a tax rounding fix.

build() {
  new_repo .
  put README.md <<'EOF'
# Shop
EOF
  put src/price.sh <<'EOF'
TAX_PERCENT=8

total() {
  echo $(( $1 + $1 * TAX_PERCENT / 100 ))
}
EOF
  commit "Add the price calculator"
  git switch -q -c release/1.0
  echo "1.0" | put VERSION
  commit "Set version 1.0"
  git switch -q main
  put src/receipt.sh <<'EOF'
receipt() { echo "Total: $(total "$1")"; }
EOF
  commit "Print a receipt"
  put src/price.sh <<'EOF'
TAX_PERCENT=8

total() {
  echo $(( $1 + ($1 * TAX_PERCENT + 50) / 100 ))
}
EOF
  commit "Fix tax rounding"
  put src/search.sh <<'EOF'
search() { grep -i "$1" products.txt; }
EOF
  commit "Add search"
}
