# Try-it: why branch -d refuses a squash-merged branch. Built by: bash lab try squash-merged
# main and feature; feature has two commits that the "server" will squash into one.

build() {
  new_repo .
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
}
