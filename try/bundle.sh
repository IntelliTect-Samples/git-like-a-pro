# Try-it: carry commits in a bundle file. Built by: bash lab try bundle
# shop/ is the repo with history; the attendee makes bundles next to it and clones offline/ from one.

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
  put src/receipt.sh <<'EOF2'
receipt() { echo "Total: $1"; }
EOF2
  commit "Print a receipt"
  echo "TAX_ROUNDING=up" >> src/price.sh
  commit "Round tax up"
}
