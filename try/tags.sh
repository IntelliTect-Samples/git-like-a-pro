# Try-it: lightweight vs. annotated tags. Built by: bash lab try tags

build() {
  new_repo .
  put README.md <<'EOF'
# Shop
EOF
  commit "Add README"
  put src/price.sh <<'EOF'
TAX_PERCENT=8
EOF
  commit "Add price settings"
  echo "SHIPPING=500" >> src/price.sh
  commit "Add shipping cost"
}
