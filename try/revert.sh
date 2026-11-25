# Try-it: undo a pushed commit with revert. Built by: bash lab try revert
# Workspace: origin.git (the shared remote) and me (your clone). Everything is pushed,
# including a bad commit one below the top.

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
    put src/price.sh <<'EOF'
TAX_PERCENT=80
EOF
    commit "Update tax"
    put src/shipping.sh <<'EOF'
SHIPPING=500
EOF
    commit "Add shipping cost"
  )
  git init -q --bare -b main origin.git
  git -C seed push -q ../origin.git main
  rm -rf seed
  git clone -q origin.git me
}
