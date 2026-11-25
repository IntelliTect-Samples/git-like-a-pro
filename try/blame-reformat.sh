# Try-it: blame past a reformat and a moved block. Built by: bash lab try blame-reformat
# Alex writes the code, Sam re-indents it (whitespace only), then Sam moves discount() to its own file.

build() {
  as_teammate
  new_repo .
  put src/price.sh <<'EOF2'
total() {
  subtotal=$1
  tax=$(( subtotal * 8 / 100 ))
  echo $(( subtotal + tax ))
}

discount() {
  amount=$1
  percent=$2
  echo $(( amount - amount * percent / 100 ))
}
EOF2
  commit "Add total and discount"
  as_author
  put src/price.sh <<'EOF2'
total() {
    subtotal=$1
    tax=$(( subtotal * 8 / 100 ))
    echo $(( subtotal + tax ))
}

discount() {
    amount=$1
    percent=$2
    echo $(( amount - amount * percent / 100 ))
}
EOF2
  commit "Reformat with 4-space indent"
  put src/price.sh <<'EOF2'
total() {
    subtotal=$1
    tax=$(( subtotal * 8 / 100 ))
    echo $(( subtotal + tax ))
}
EOF2
  put src/discount.sh <<'EOF2'
discount() {
    amount=$1
    percent=$2
    echo $(( amount - amount * percent / 100 ))
}
EOF2
  commit "Move discount to its own file"
}
