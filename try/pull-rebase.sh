# Try-it: pull vs. pull --rebase on the same divergence. Built by: bash lab try pull-rebase
# Workspace: origin.git (the shared remote) and me (your clone). A teammate pushed one commit
# that "me" hasn't fetched yet, and "me" has one commit of its own that isn't pushed.

build() {
  new_repo seed
  (
    cd seed || exit 1
    put README.md <<'EOF'
# Shop
EOF
    commit "Add README"
    put src/price.sh <<'EOF'
TAX_PERCENT=8
EOF
    commit "Add price settings"
  )
  git init -q --bare -b main origin.git
  git -C seed push -q ../origin.git main
  rm -rf seed
  git clone -q origin.git me
  git clone -q origin.git alex
  (
    cd alex || exit 1
    as_teammate
    echo "SHIPPING=500" >> src/price.sh
    commit "Add shipping cost"
    git push -q origin main
  )
  rm -rf alex
  cd me || exit 1
  put src/receipt.sh <<'EOF'
receipt() { echo "Total: $1"; }
EOF
  commit "Print a receipt"
}
