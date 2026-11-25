# Try-it: reset --soft, --mixed and --hard on the same commit. Built by: bash lab try reset-modes
# The last commit, "Add a 10% discount", changes src/price.sh; each reset moves main back past it.

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
  echo "DISCOUNT_PERCENT=10" >> src/price.sh
  commit "Add a 10% discount"
}
