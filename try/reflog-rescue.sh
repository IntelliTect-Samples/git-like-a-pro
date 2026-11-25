# Try-it: get a deleted branch back from the reflog. Built by: bash lab try reflog-rescue
# experiment has two commits that aren't on main; the last thing done was switching back to main.

build() {
  new_repo .
  put README.md <<'EOF'
# Shop
EOF
  put src/price.sh <<'EOF'
TAX_PERCENT=8
EOF
  commit "Add README and price settings"
  git switch -q -c experiment
  put src/coupon.sh <<'EOF'
COUPON_PERCENT=15
EOF
  commit "Try coupons"
  echo "COUPON_LIMIT=1" >> src/coupon.sh
  commit "Limit coupons to one per order"
  git switch -q main
  echo "SHIPPING=500" >> src/price.sh
  commit "Add shipping cost"
}
