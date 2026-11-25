# Try-it: --ff-only refusing, then --no-ff. Built by: bash lab try ff-only
# docs is directly ahead of main (it can fast-forward); feature branched off earlier, so main has moved on.

build() {
  new_repo .
  put README.md <<'EOF'
# Shop
EOF
  commit "Add README"
  git branch feature
  put src/price.sh <<'EOF'
TAX_PERCENT=8
EOF
  commit "Add price settings"
  git switch -q -c docs
  put docs/prices.md <<'EOF'
Prices are in cents. Tax is 8%.
EOF
  commit "Document prices"
  git switch -q feature
  put src/receipt.sh <<'EOF'
receipt() { echo "Total: $1"; }
EOF
  commit "Print a receipt"
  git switch -q main
}
