# Try-it: stash -u and stash branch. Built by: bash lab try stash-branch
# Starts with half-done work: a change to src/price.sh and a new, untracked src/search.sh.
TRY_DIRTY=1

build() {
  new_repo .
  put README.md <<'EOF'
# Shop
EOF
  put src/price.sh <<'EOF'
TAX_PERCENT=8
EOF
  commit "Add README and price settings"
  echo "SHIPPING=500" >> src/price.sh
  commit "Add shipping cost"
  # Half-done work, not committed.
  echo "SEARCH_RESULTS_PER_PAGE=20" >> src/price.sh
  put src/search.sh <<'EOF'
search() { grep -i "$1" products.txt; }
EOF
}
