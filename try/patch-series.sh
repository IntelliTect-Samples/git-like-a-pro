# Try-it: format-patch two commits, git am them into another repo. Built by: bash lab try patch-series
# shop/ has a feature branch with two commits; offline/ is a copy of shop's main with no remote.

build() {
  new_repo shop
  cd shop || return 1
  put README.md <<'EOF2'
# Shop

Prices are in cents.
EOF2
  put src/price.sh <<'EOF2'
TAX_PERCENT=8
EOF2
  commit "Add README and price settings"
  git switch -q -c feature
  put src/discount.sh <<'EOF2'
DISCOUNT_PERCENT=10
EOF2
  commit "Add a discount setting"
  echo "Discounts apply before tax." >> README.md
  commit "Explain discounts"
  git switch -q main
  cd ..
  git clone -q shop offline
  git -C offline remote remove origin
}
