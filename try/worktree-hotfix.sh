# Try-it: a hotfix in a second worktree while a feature has uncommitted changes.
# Built by: bash lab try worktree-hotfix
# The repo is in shop/ so the second worktree (../hotfix) lands inside the workspace.

TRY_DIRTY=1 # shop/ starts with an uncommitted change on feature, on purpose

build() {
  new_repo shop
  cd shop || return 1
  put README.md <<'EOF2'
# Shop

Prices are in cents.
EOF2
  put src/tax.sh <<'EOF2'
TAX_PERCENT=80
EOF2
  put src/receipt.sh <<'EOF2'
receipt() { echo "Total: $1"; }
EOF2
  commit "Add tax and receipts"
  git switch -q -c feature
  echo "receipt_footer() { echo 'Thank you!'; }" >> src/receipt.sh
  commit "Add a receipt footer"
  # Half-done work, not committed yet.
  echo "receipt_header() { echo 'Shop receipt'; }" >> src/receipt.sh
}
