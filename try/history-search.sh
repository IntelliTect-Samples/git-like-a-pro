# Try-it: find when a line appeared with log -S, and compare A..B with A...B.
# Built by: bash lab try history-search

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
  put src/receipt.sh <<'EOF2'
receipt() { echo "Total: $1"; }
EOF2
  commit "Print a receipt"
  put src/shipping.sh <<'EOF2'
SHIPPING_COST=500
FREE_SHIPPING_OVER=5000
EOF2
  echo "Shipping is free on big orders." >> README.md
  commit "Add shipping costs"
  echo "receipt_footer() { echo 'Thank you!'; }" >> src/receipt.sh
  commit "Add a receipt footer"
  put src/shipping.sh <<'EOF2'
SHIPPING_COST=500
FREE_SHIPPING_OVER=7500
EOF2
  commit "Raise the free shipping limit"
  git switch -q -c feature
  put src/loyalty.sh <<'EOF2'
POINTS_PER_DOLLAR=1
EOF2
  commit "Add loyalty points"
  echo "POINTS_FOR_REVIEW=50" >> src/loyalty.sh
  commit "Give points for reviews"
  echo "Loyalty points never expire." >> README.md
  commit "Document loyalty points"
  git switch -q main
  echo "TAX_ROUNDING=up" >> src/price.sh
  commit "Round tax up"
  echo "Tax is rounded up to the next cent." >> README.md
  commit "Document tax rounding"
}
