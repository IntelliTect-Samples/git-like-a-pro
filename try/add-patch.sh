# Try-it: add -p with split (s) and edit (e). Built by: bash lab try add-patch
# Starts with uncommitted changes in src/price.sh: two hunks, each mixing work to stage and work to leave out.
TRY_DIRTY=1

add_patch_price() { # add_patch_price <tax> <currency> <debug yes|no> <test>
  {
    echo "# Price settings and calculation. Amounts are in cents."
    echo "TAX_PERCENT=$1"
    echo "SHIPPING=500"
    echo "FREE_SHIPPING_FROM=5000"
    echo "CURRENCY=$2"
    cat <<'EOF'

# total <subtotal>: the subtotal plus tax
total() {
  local subtotal=$1
  echo $(( subtotal + subtotal * TAX_PERCENT / 100 ))
}

# shipping <subtotal>: what shipping costs for this order
shipping() {
  local subtotal=$1
EOF
    if [ "$3" = yes ]; then echo '  echo "debug: subtotal=$subtotal" >&2'; fi
    echo "  if [ \"\$subtotal\" $4 \"\$FREE_SHIPPING_FROM\" ]; then"
    cat <<'EOF'
    echo 0
  else
    echo "$SHIPPING"
  fi
}
EOF
  } | put src/price.sh
}

build() {
  new_repo .
  add_patch_price 8 USD no -gt
  commit "Add price settings and calculation"
  # Uncommitted: a tax change (stage it) next to a currency experiment (don't),
  # and a shipping fix (stage it) next to a debug line (don't).
  add_patch_price 9 EUR yes -ge
}
