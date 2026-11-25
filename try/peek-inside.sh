# Try-it: peek inside a commit, its tree and a blob. Built by: bash lab try peek-inside

build() {
  new_repo .
  put README.md <<'EOF'
# Shop
EOF
  put src/price.sh <<'EOF'
TAX_PERCENT=8
EOF
  commit "Add README and price settings"
  echo "Prices are in cents." >> README.md
  commit "Explain prices"
}
